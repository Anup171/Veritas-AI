#!/bin/sh
set -eu

verify_writable_directory() {
    directory="$1"
    probe="$directory/.write-probe-$$"

    mkdir -p "$directory"
    : > "$probe"
    rm -f "$probe"
}

# These paths can be mounted by Compose. Verify that the unprivileged process
# can write before Chainlit starts, so a permissions error is clear and early.
verify_writable_directory /app/outputs
verify_writable_directory /app/.cache

exec "$@"
