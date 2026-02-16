# La Revira Flutter

App móvil Flutter (iOS/Android) para Semana Santa, conectada a la API de `larevira-gest`.

## Run en iPhone (VSCode o terminal)

Usa `API_BASE_URL` con la IP LAN de tu Mac (no `localhost` desde iPhone):

```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.1.89:8001/api/v1 \
  --dart-define=CITY_SLUG=sevilla \
  --dart-define=EDITION_YEAR=2026 \
  --dart-define=MODE=all \
  -d 00008130-0009189C1A32001C
```

## Variables de entorno (`--dart-define`)

- `API_BASE_URL`: base de la API v1
- `CITY_SLUG`: ciudad (ej. `sevilla`)
- `EDITION_YEAR`: año de edición (ej. `2026`)
- `MODE`: `all`, `live` u `official`

## Estructura inicial

- `Hoy`: resumen de jornadas
- `Jornadas`: listado por modo (`all/live/official`)
- `Hermandades`: listado de hermandades
- `Más`: configuración activa y próximos módulos

## Conectividad limitada

- Todas las peticiones `GET` usan caché local automática.
- Si falla la red, la app intenta mostrar la última respuesta guardada.
- Reintento corto automático para errores transitorios de conexión.
- En detalle de jornada, el modo en vivo arranca en pausa para ahorrar datos.
- Sincronización masiva offline automática al arrancar (si está desactualizada).
- En pestaña `Más` existe botón manual `Descargar datos offline ahora`.

Importante:
- Si el usuario abre la app por primera vez sin conexión, no habrá datos remotos precargados.
- Para cubrir ese caso, la recomendación operativa es abrir la app antes del evento y lanzar la sincronización offline.

## Companion Watch (híbrido)

La app iOS expone snapshot de jornadas al Watch mediante `WatchConnectivity`.

- Bridge: `/Users/manuel/Proyectos/La revirá/larevira-app-flutter/ios/Runner/WatchSyncBridge.swift`
- Config companion: `/Users/manuel/Proyectos/La revirá/larevira-app-flutter/ios/Runner/WatchSyncConfig.swift`

Comportamiento esperado:
- Si hay iPhone disponible, el Watch usa snapshot del iPhone.
- Si no, el Watch cae a consumo directo de API (modo autónomo).
