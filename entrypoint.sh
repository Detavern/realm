#!/bin/bash

# Get the PUID and PGID from environment variables (or use default values 1000 if not set)
PUID=${PUID:-1000}
PGID=${PGID:-1000}
APPUSER=${APPUSER:-"realm"}

# Check if the provided PUID and PGID are non-empty, numeric values; otherwise, assign default values.
if ! [[ "$PUID" =~ ^[0-9]+$ ]]; then
  PUID=1000
fi
if ! [[ "$PGID" =~ ^[0-9]+$ ]]; then
  PGID=1000
fi

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
