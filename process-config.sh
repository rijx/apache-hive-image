#!/bin/bash -e

[[ ! -z "$HIVE_CONF_DIR_SRC" ]] && [[ -d "$HIVE_CONF_DIR_SRC" ]] || exit

for x in "$HIVE_CONF_DIR_SRC"/*; do
  filename="$(basename "$x")"
  envsubst < "$HIVE_CONF_DIR_SRC/$filename" > "$HIVE_CONF_DIR/$filename"
done

exec /entrypoint.sh "$@"
