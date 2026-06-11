# 🔐 Configuración de Secrets para CI

## 1. Generar keystore local (una sola vez)

```bash
keytool -genkey -v \
  -keystore release.keystore \
  -alias combate_movil_release \
  -keyalg RSA -keysize 2048 \
  -validity 10000
```

## 2. Codificar en Base64

```bash
# Linux
base64 -w 0 release.keystore > release.keystore.b64

# macOS
base64 -i release.keystore -o release.keystore.b64
```

## 3. Cargar Secrets en GitHub

GitHub → Settings → Secrets and variables → Actions → New repository secret

| Nombre (EXACTO) | Valor |
|---|---|
| `RELEASE_KEYSTORE_BASE64` | Contenido completo de `release.keystore.b64` |
| `KEYSTORE_PASSWORD` | Contraseña del keystore (storepass) usada al generar |
| `KEY_ALIAS` | `combate_movil_release` |
| `KEY_PASSWORD` | Contraseña del alias (keypass) usada al generar |

> Estos 4 nombres deben coincidir EXACTAMENTE con los que lee el workflow.
> NO uses `GODOT_ANDROID_KEYSTORE_RELEASE_*` como nombres de Secret.

## 4. Probar el workflow

GitHub → Actions → "Build Android APK" → Run workflow

Si todo está bien configurado, en ~5 minutos tendrás un artifact `combate-movil-apk` descargable.
