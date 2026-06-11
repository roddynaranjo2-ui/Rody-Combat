# Combate Móvil 2.5D — Fase 0 preparada

Repositorio base de infraestructura para CI/CD de Android con Godot 4.3.0-stable.

## Qué incluye esta Fase 0

- `.gitignore` para Godot 4 + secretos
- `.gitattributes` con Git LFS para binarios pesados
- Workflow de build Android firmado (`.github/workflows/build_android.yml`)
- Workflow de lint opcional (`.github/workflows/lint.yml`)
- Guía de secrets (`docs/CI_SECRETS.md`)
- Script auxiliar de decode del keystore (`tools/decode_keystore.sh`)

## Requisitos previos

1. Crear repo vacío en GitHub.
2. Ejecutar en local:
   ```bash
   git lfs install
   ```
3. Configurar los 4 secrets exactos:
   - `RELEASE_KEYSTORE_BASE64`
   - `KEYSTORE_PASSWORD`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`

## Notas importantes

- Runner CI: `ubuntu-22.04`
- Godot exacto: `4.3.0-stable`
- No se instala Java/Android SDK en esta fase (flujo con plantilla APK simple)
- El `version/code` se sobrescribe con `${{ github.run_number }}`
- Nunca commitear `release.keystore`
