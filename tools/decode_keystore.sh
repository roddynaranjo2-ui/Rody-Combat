#!/usr/bin/env bash
# Decodifica el keystore desde RELEASE_KEYSTORE_BASE64
# y lo coloca en $HOME/keystores/release.keystore.

set -euo pipefail

DEST_DIR="${HOME}/keystores"
DEST_FILE="${DEST_DIR}/release.keystore"

if [[ -z "${RELEASE_KEYSTORE_BASE64:-}" ]]; then
    echo "ERROR: RELEASE_KEYSTORE_BASE64 no está definida." >&2
    exit 1
fi

mkdir -p "${DEST_DIR}"
echo "${RELEASE_KEYSTORE_BASE64}" | base64 --decode > "${DEST_FILE}"
chmod 600 "${DEST_FILE}"

# Para build local por entorno (source tools/decode_keystore.sh)
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="${DEST_FILE}"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="${KEY_ALIAS:-combate_movil_release}"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="${KEYSTORE_PASSWORD:-}"
export GODOT_ANDROID_KEYSTORE_RELEASE_KEY_PASSWORD="${KEY_PASSWORD:-}"

echo "Keystore decodificado en: ${DEST_FILE}"
echo "Variables GODOT_ANDROID_KEYSTORE_RELEASE_* exportadas."
