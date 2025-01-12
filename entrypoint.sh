#!/bin/bash

# Get the PUID and PGID from environment variables (or use default values if not set)
PUID=${PUID:-0}
PGID=${PGID:-0}
APPUSER=${APPUSER:-"realm"}

# Check if the provided PUID and PGID are non-empty, numeric values; otherwise, assign default values.
if ! [[ "$PUID" =~ ^[0-9]+$ ]]; then
  PUID=0
fi
if ! [[ "$PGID" =~ ^[0-9]+$ ]]; then
  PGID=0
fi

# Check if PUID and PGID are set to zero
if [ "$PUID" -eq 0 ] && [ "$PGID" -eq 0 ]; then
    exec "$@"
else
    # Check if the specified group with PGID exists, if not, create it.
    if ! getent group "$PGID" >/dev/null; then
        groupadd -g "$PGID" "$APPUSER"
    fi
    # Create user if it doesn't exist.
    if ! getent passwd "$PUID" >/dev/null; then
        useradd -m -s /bin/bash -u "$PUID" -g "$PGID" "$APPUSER"
    fi

    # Switch to appuser and execute the Docker CMD or passed in command-line arguments.
    # Using setpriv let's it run as PID 1 which is required for proper signal handling (similar to gosu/su-exec).
    exec setpriv --reuid=$PUID --regid=$PGID --init-groups $@
fi
