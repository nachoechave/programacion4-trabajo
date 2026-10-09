# API v1 — Autenticación por token

Todos los endpoints de consulta requieren un token Bearer.

## Iniciar sesión

`POST /api/v1/login` con body JSON:

```json
{"email":"admin@example.com","password":"password123"}
```

Devuelve `token`, `token_type` y `expires_in`. Los tokens vencen a las 24 horas.

En las siguientes solicitudes enviar `Authorization: Bearer TOKEN`.

`DELETE /api/v1/logout` revoca el token actual.

Los usuarios desactivados y los tokens vencidos reciben HTTP 401.
Los analistas no pueden crear casos por API (HTTP 403).

## Casos

- `GET /api/v1/cases`
- `GET /api/v1/cases/:id`
- `POST /api/v1/cases` (solo administradores)

## Evidencias

- `GET /api/v1/evidences`
- `GET /api/v1/evidences/:id`
- `GET /api/v1/evidences/:evidence_id/custody_movements`

Las operaciones de lectura no modifican la cadena de custodia.

## Back-office

Los administradores gestionan las evidencias, sus archivos adjuntos y los reportes PDF desde la interfaz web.
