#!/usr/bin/env bash

#
#          M""""""""`M            dP
#          Mmmmmm   .M            88
#          MMMMP  .MMM  dP    dP  88  .dP   .d8888b.
#          MMP  .MMMMM  88    88  88888"    88'  `88
#          M' .MMMMMMM  88.  .88  88  `8b.  88.  .88
#          M         M  `88888P'  dP   `YP  `88888P'
#          MMMMMMMMMMM    -*-  Created by Zuko  -*-
#
#          * * * * * * * * * * * * * * * * * * * * *
#          * -    - -   F.R.E.E.M.I.N.D   - -    - *
#          * -  Copyright © 2026 (Z) Programing  - *
#          *    -  -  All Rights Reserved  -  -    *
#          * * * * * * * * * * * * * * * * * * * * *
#
LOCAL_ALIAS_STORAGE="${HOME}/.shell_aliases.json"
GLOBAL_ALIAS_STORAGE="/usr/share/.shell_aliases.json"

_register_alias() {
    alias "$1"="$2"
}

set_alias() {
    local target_file="$LOCAL_ALIAS_STORAGE"
    
    # Parse boolean flag -g
    if [ "$1" = "-g" ]; then
        if [ "$EUID" -ne 0 ]; then
            echo -e "\e[31mError: Root privileges required for global store (-g).\e[0m" >&2
            return 1
        fi
        target_file="$GLOBAL_ALIAS_STORAGE"
        shift
    fi

    local k="$1"
    local v="$2"

    if [ -z "$k" ] || [ -z "$v" ]; then
        echo "Usage: set_alias [-g] <key> <value>"
        return 1
    fi

    python3 -c '
import sys, json
file_path, k, v = sys.argv[1:4]
try:
    with open(file_path, "r") as f: 
        data = json.load(f)
except Exception:
    data = {}
data[k] = v
with open(file_path, "w") as f: 
    json.dump(data, f, indent=4)
' "$target_file" "$k" "$v"

    _register_alias "$k" "$v"
    echo -e "\e[32mAdded alias: $k -> $v (Store: $target_file)\e[0m"
}

for store_file in "$GLOBAL_ALIAS_STORAGE" "$LOCAL_ALIAS_STORAGE"; do
    if [ -f "$store_file" ]; then
        echo -e "\e[32mLoading shell aliases from (Store: $store_file)\e[0m"
        eval "$(python3 -c '
import sys, json, shlex
try:
    with open(sys.argv[1], "r") as f:
        for k, v in json.load(f).items():
            print(f"alias {shlex.quote(k)}={shlex.quote(v)}")
except Exception:
    pass
' "$store_file")"
    fi
done
alias setalias set_alias
