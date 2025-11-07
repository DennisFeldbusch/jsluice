#!/bin/sh
set -e

# If no args provided, show help
if [ "$#" -eq 0 ]; then
  exec /usr/local/bin/jsluice --help
fi

# If the first arg starts with a dash, it's flags for jsluice -> prepend binary
case "$1" in
  -*) set -- /usr/local/bin/jsluice "$@" ;;
  *)
    # If the first arg is an existing command in PATH (e.g., sh, bash), run it
    if command -v "$1" >/dev/null 2>&1; then
      exec "$@"
    fi
    # Otherwise treat the args as subcommands/flags for jsluice
    set -- /usr/local/bin/jsluice "$@"
    ;;
esac

exec "$@"
