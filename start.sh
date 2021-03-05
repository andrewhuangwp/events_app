#!/bin/bash

export MIX_ENV=prod
export PORT=5231

CFGD=$(readlink -f ~/.config/events)

if [ ! -e "$CFGD/base" ]; then
    echo "run deploy first"
    exit 1
fi

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

DB_PASS=$(cat "$CFGD/db_pass")
export DATABASE_URL=ecto://events_app:$DB_PASS@localhost/events_app_prod

_build/prod/rel/events_app/bin/events_app start