#!/bin/bash

# =================================================================
# POSTGRESQL PERMISSION MANAGER (With Safety Lock)
# Usage: ./manage_pg.sh [--allow-drop]
# =================================================================

# CONFIG
PG_PORT=5433
ALLOW_DROP=false

# CHECK HIDDEN FLAG
if [[ "$1" == "--allow-drop" ]]; then
    ALLOW_DROP=true
fi

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# CHECK ROOT
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script must be run as root (sudo).${NC}" 
   exit 1
fi

echo -e "${CYAN}--- POSTGRESQL MANAGER (Port: $PG_PORT) ---${NC}"
if [ "$ALLOW_DROP" = true ]; then
    echo -e "${RED}[WARNING] UNRESTRICTED MODE: 'DROP TABLE' privileges will be allowed.${NC}"
fi

# HELPER FUNCTIONS
run_sql() {
    su - postgres -c "psql -p $PG_PORT -t -A"
}
run_sql_exec() {
    su - postgres -c "psql -p $PG_PORT"
}

# =================================================================
# STEP 1: SELECT USER
# =================================================================
echo -e "\n${YELLOW}[STEP 1] SELECT USER:${NC}"

USER_LIST_STR=$(run_sql <<EOF
SELECT usename FROM pg_user 
WHERE usename NOT LIKE 'pg_%' AND usename != 'postgres' ORDER BY usename;
EOF
)
IFS=$'\n' read -rd '' -a USERS <<< "$USER_LIST_STR"

i=1
for u in "${USERS[@]}"; do [[ -n "$u" ]] && echo "  $i. $u" && ((i++)); done
echo "  0. [+] CREATE NEW USER"

read -p ">> Select (0-$((i-1))): " U_CHOICE

if [ "$U_CHOICE" -eq 0 ]; then
    read -p "   -> New Username: " NEW_USER_NAME
    read -s -p "   -> New Password: " NEW_USER_PASS; echo ""
    SELECTED_USER="$NEW_USER_NAME"
    NEW_USER_SQL="CREATE USER \"$NEW_USER_NAME\" WITH PASSWORD '$NEW_USER_PASS'; ALTER USER \"$NEW_USER_NAME\" NOSUPERUSER;"
else
    INDEX=$((U_CHOICE-1))
    SELECTED_USER="${USERS[$INDEX]}"
    [[ -z "$SELECTED_USER" ]] && echo -e "${RED}Invalid!${NC}" && exit 1
fi
echo -e "${GREEN}=> User: $SELECTED_USER${NC}"

# =================================================================
# STEP 2: SELECT DATABASE
# =================================================================
echo -e "\n${YELLOW}[STEP 2] SELECT DATABASE:${NC}"

DB_LIST_STR=$(run_sql <<EOF
SELECT datname FROM pg_database 
WHERE datistemplate = false AND datname != 'postgres' ORDER BY datname;
EOF
)
IFS=$'\n' read -rd '' -a DBS <<< "$DB_LIST_STR"

j=1
for d in "${DBS[@]}"; do [[ -n "$d" ]] && echo "  $j. $d" && ((j++)); done
echo "  0. [+] CREATE NEW DATABASE"

read -p ">> Select (0-$((j-1))): " D_CHOICE

if [ "$D_CHOICE" -eq 0 ]; then
    read -p "   -> New DB Name: " NEW_DB_NAME
    SELECTED_DB="$NEW_DB_NAME"
    NEW_DB_SQL="CREATE DATABASE \"$NEW_DB_NAME\";"
else
    INDEX=$((D_CHOICE-1))
    SELECTED_DB="${DBS[$INDEX]}"
    [[ -z "$SELECTED_DB" ]] && echo -e "${RED}Invalid!${NC}" && exit 1
fi
echo -e "${GREEN}=> DB: $SELECTED_DB${NC}"

# =================================================================
# STEP 3: CONSTRUCT SQL (LOGIC CORE)
# =================================================================

# Logic for Safety Lock (Event Trigger)
# We create a function that raises exception if the specific user tries to DROP TABLE
SAFETY_LOGIC=""

if [ "$ALLOW_DROP" = false ]; then
    SAFETY_LOGIC="
-- [SAFETY LOCK] Prevent DROP TABLE for user '$SELECTED_USER'
CREATE OR REPLACE FUNCTION public.prevention_drop_guard()
RETURNS event_trigger LANGUAGE plpgsql AS \$\$
BEGIN
    IF session_user = '$SELECTED_USER' THEN
        RAISE EXCEPTION 'PERMISSION DENIED: You are allowed to ALTER, but NOT to DROP tables. Contact Admin.';
    END IF;
END;
\$\$;

-- Create Trigger if not exists (Drop first to ensure clean state)
DROP EVENT TRIGGER IF EXISTS safety_lock_trigger;
CREATE EVENT TRIGGER safety_lock_trigger ON ddl_command_start
WHEN TAG IN ('DROP TABLE', 'DROP SEQUENCE', 'DROP MATERIALIZED VIEW')
EXECUTE FUNCTION public.prevention_drop_guard();
"
else
    SAFETY_LOGIC="
-- [UNRESTRICTED] removing safety locks if they exist
DROP EVENT TRIGGER IF EXISTS safety_lock_trigger;
DROP FUNCTION IF EXISTS public.prevention_drop_guard();
"
fi

# Final SQL Construction
FINAL_SQL_CONTENT="
-- 1. Setup User/DB
$NEW_USER_SQL
$NEW_DB_SQL

-- 2. Basic Connection & Public Schema
GRANT CONNECT ON DATABASE \"$SELECTED_DB\" TO \"$SELECTED_USER\";
\c \"$SELECTED_DB\"
GRANT USAGE, CREATE ON SCHEMA public TO \"$SELECTED_USER\";

-- 3. [CRITICAL] TRANSFER OWNERSHIP
-- To allow migrations (ALTER TABLE), the user MUST be the owner.
DO \$\$
DECLARE r record;
BEGIN
   -- Transfer Tables
   FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
      EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' OWNER TO \"$SELECTED_USER\";';
   END LOOP;
   -- Transfer Sequences
   FOR r IN SELECT sequencename FROM pg_sequences WHERE schemaname = 'public' LOOP
      EXECUTE 'ALTER SEQUENCE public.' || quote_ident(r.sequencename) || ' OWNER TO \"$SELECTED_USER\";';
   END LOOP;
   -- Transfer Views
   FOR r IN SELECT table_name FROM information_schema.views WHERE table_schema = 'public' LOOP
      EXECUTE 'ALTER VIEW public.' || quote_ident(r.table_name) || ' OWNER TO \"$SELECTED_USER\";';
   END LOOP;
END \$\$;

-- 4. Future Defaults
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"$SELECTED_USER\";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"$SELECTED_USER\";

-- 5. Safety Mechanism (Allow ALTER, Ban DROP)
$SAFETY_LOGIC
"

echo -e "\n${YELLOW}=== REVIEW COMMANDS ===${NC}"
echo "$FINAL_SQL_CONTENT"
echo -e "${YELLOW}=======================${NC}"

read -p "Type 'YES' to execute: " CONFIRM

if [ "$CONFIRM" == "YES" ]; then
    echo -e "\n${CYAN}Executing...${NC}"
    run_sql_exec <<EOF
$FINAL_SQL_CONTENT
EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Ownership transferred & Permissions applied.${NC}"
        if [ "$ALLOW_DROP" = false ]; then
             echo -e "${GREEN}[NOTE] 'DROP TABLE' is BLOCKED for user '$SELECTED_USER'.${NC}"
        fi
    else
        echo -e "${RED}[ERROR] Execution failed.${NC}"
    fi
else
    echo -e "${RED}[CANCELLED]${NC}"
fi
