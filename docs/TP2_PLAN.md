# TP2 — Plan de integración Angular + Rails

## Estado inicial verificado (18/11/2026)
Backend Rails 8.1, PostgreSQL, back-office ERB y autenticación Bearer existentes. El backend debe seguir funcionando sin reemplazar sus vistas administrativas.

### Endpoints existentes
- POST /api/v1/login (email, password): devuelve token Bearer y expires_in.
- DELETE /api/v1/logout: revoca token.
- GET /api/v1/cases, GET /api/v1/cases/:id.
- POST /api/v1/cases: solo administrador; body {case: {...}}.
- GET /api/v1/evidences, GET /api/v1/evidences/:id.
- GET /api/v1/evidences/:evidence_id/custody_movements.

### Brechas para un flujo completo de usuario final
- Crear frontend Angular en repositorio propio (recomendación del enunciado).
- API para perfil actual, tipos de evidencia, alta de evidencias y transferencia de custodia, con autorización por rol y caso.
- Revisar acceso de analistas a casos y evidencias: no exponer registros no asignados.
- Definir manejo de CORS y tokens sin exponer secretos ni almacenarlos innecesariamente.
- Documentar contrato API y errores JSON.
- Tests backend (éxito, validación, autenticación, permisos), frontend (éxito y error) y demostración contra API real.
- Comprobar RuboCop, Brakeman, tests y compilación Angular antes de marcar entrega lista.

## Despliegue previsto
- Frontend: https://tp4.comercioflex.com.ar
- API Rails: servicio separado y protegido por HTTPS, con host propio a definir, o proxy /api en el mismo host.
- PostgreSQL y almacenamiento persistente exclusivos; NO compartir base ni volumen con Comercio Flex.
- En Easypanel: app Angular estática servida con Nginx y app Rails Docker independiente; configuración SPA fallback.
- Configurar host permitido, CORS si hay orígenes distintos, TLS, healthcheck, backup, variables de entorno y volumen /app/storage.
- Nunca ejecutar db:seed demo automáticamente en producción.

## Orden de trabajo
1. Auditoría completa de modelos, controladores, permisos, pruebas y CI.
2. Ampliar API Rails con tests.
3. Crear repo Angular y construir login, dashboard, casos, evidencias y movimientos.
4. Integrar con API real, documentar y probar errores.
5. Preparar Dockerfiles, configuración de Easypanel y checklist de despliegue.
6. Abrir PR; merge y publicación solo después de revisión.
