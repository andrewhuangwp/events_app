#!/bin/bash

export SECRET_KEY_BASE=W68eso5YQOlbtvSNUR50N/HDWj6IaEhAwMR3LtzuBEQAefwYVbX84bvoTA7XtiGi
export MIX_ENV=prod
export PORT=5231
export DATABASE_URL=ecto://events_app:iekey1Sohx5c@localhost:5231/events_app_prod


echo "Stopping old copy of app, if any..."

_build/prod/rel/events_app/bin/events_app stop || true

echo "Starting app..."

export PORT=5231
_build/prod/rel/events_app/bin/events_app start