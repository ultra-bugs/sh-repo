#!/bin/bash

# POSTGRES CONFIGURATION
PG_PORT=5433

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# CHECK ROOT PRIVILEGES
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script must be run as root (sudo).${NC}" 
   exit 1
fi

echo -e "${CYAN}--- POSTGRESQL PERMISSION MANAGER (Port: $PG_PORT) ---${NC}"

# =================================================================
# FUNCTION: RUN SQL (Using Heredoc to avoid quoting hell)
# =================================================================
# This function reads SQL from stdin and executes it as the postgres user
run_sql() {
    # -t: Tuples only (turn off header)
    # -A: Unaligned (turn off formatting, for easy parsing)
    su - postgres -c "psql -p $PG_PORT -t -A"
}

run_sql_exec() {
    # Used for actual execution (shows output/errors)
    su - postgres -c "psql -p $PG_PORT"
}

# =================================================================
# STEP 1: FETCH USERS & DISPLAY MENU
# =================================================================
echo -e "\n${YELLOW}[STEP 1] SELECT USER:${NC}"

# Use Heredoc to pass SQL cleanly
USER_LIST_STR=$(run_sql <<EOF
SELECT usename FROM pg_user 
WHERE usename NOT LIKE 'pg_%' 
  AND usename != 'postgres' 
ORDER BY usename;
EOF
)

IFS=$'\n' read -rd '' -a USERS <<< "$USER_LIST_STR"

i=1
for u in "${USERS[@]}"; do
    [[ -n "$u" ]] && echo "  $i. $u" && ((i++))
done
echo "  0. [+] CREATE NEW USER"

read -p ">> Select option (0-$((i-1))): " U_CHOICE

SELECTED_USER=""
NEW_USER_SQL=""

if [ "$U_CHOICE" -eq 0 ]; then
    read -p "   -> Enter new Username: " NEW_USER_NAME
    read -s -p "   -> Enter Password: " NEW_USER_PASS
    echo ""
    SELECTED_USER="$NEW_USER_NAME"
    # Store creation SQL to run later
    NEW_USER_SQL="CREATE USER \"$NEW_USER_NAME\" WITH PASSWORD '$NEW_USER_PASS'; ALTER USER \"$NEW_USER_NAME\" NOSUPERUSER;"
else
    INDEX=$((U_CHOICE-1))
    SELECTED_USER="${USERS[$INDEX]}"
    [[ -z "$SELECTED_USER" ]] && echo -e "${RED}Invalid selection!${NC}" && exit 1
fi
echo -e "${GREEN}=> Selected User: $SELECTED_USER${NC}"

# =================================================================
# STEP 2: FETCH DATABASES & DISPLAY MENU
# =================================================================
echo -e "\n${YELLOW}[STEP 2] SELECT DATABASE:${NC}"

DB_LIST_STR=$(run_sql <<EOF
SELECT datname FROM pg_database 
WHERE datistemplate = false 
  AND datname != 'postgres' 
ORDER BY datname;
EOF
)

IFS=$'\n' read -rd '' -a DBS <<< "$DB_LIST_STR"

j=1
for d in "${DBS[@]}"; do
    [[ -n "$d" ]] && echo "  $j. $d" && ((j++))
done
echo "  0. [+] CREATE NEW DATABASE"

read -p ">> Select option (0-$((j-1))): " D_CHOICE

SELECTED_DB=""
NEW_DB_SQL=""

if [ "$D_CHOICE" -eq 0 ]; then
    read -p "   -> Enter new Database Name: " NEW_DB_NAME
    SELECTED_DB="$NEW_DB_NAME"
    NEW_DB_SQL="CREATE DATABASE \"$NEW_DB_NAME\";"
else
    INDEX=$((D_CHOICE-1))
    SELECTED_DB="${DBS[$INDEX]}"
    [[ -z "$SELECTED_DB" ]] && echo -e "${RED}Invalid selection!${NC}" && exit 1
fi
echo -e "${GREEN}=> Selected DB: $SELECTED_DB${NC}"

# =================================================================
# STEP 3: GENERATE SQL & EXECUTE
# =================================================================

# Construct the final SQL block
# Bash variables ($SELECTED_DB, etc.) will be expanded here
FINAL_SQL_CONTENT="
-- 1. Setup User/DB (if new)
$NEW_USER_SQL
$NEW_DB_SQL

-- 2. Grant Connection Privileges
GRANT CONNECT ON DATABASE \"$SELECTED_DB\" TO \"$SELECTED_USER\";

-- 3. Grant Public Schema Usage & Privileges
\c \"$SELECTED_DB\"
GRANT USAGE, CREATE ON SCHEMA public TO \"$SELECTED_USER\";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$SELECTED_USER\";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$SELECTED_USER\";

-- 4. Grant Future Privileges (Default Privileges)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"$SELECTED_USER\";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"$SELECTED_USER\";
"

echo -e "\n${YELLOW}=== REVIEW COMMANDS TO BE EXECUTED ===${NC}"
echo "$FINAL_SQL_CONTENT"
echo -e "${YELLOW}======================================${NC}"

read -p "Type 'YES' to execute: " CONFIRM

if [ "$CONFIRM" == "YES" ]; then
    echo -e "\n${CYAN}Executing...${NC}"
    
    # Pipe the final SQL into psql via Heredoc
    run_sql_exec <<EOF
$FINAL_SQL_CONTENT
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Permissions granted for '$SELECTED_USER' on DB '$SELECTED_DB'.${NC}"
    else
        echo -e "${RED}[ERROR] An error occurred during execution.${NC}"
    fi
else
    echo -e "${RED}[CANCELLED] No changes were made.${NC}"
fi
