#!/bin/bash
set -e

mkdir -p tmp/cache log
chmod -R 777 tmp log
# Remove server PID if it exists
rm -f tmp/pids/server.pid

# Run migrations (safe to run multiple times)
if [ "$RAILS_ROLE" = "web" ]; then
  echo "Running migrations..."
  bin/rails db:migrate
fi

# Execute the command passed to container
exec "$@"
