# Digital Custody — TP2 (Angular + Rails)

Frontend real integrado con el backend del TP1, que permanece en la raíz del repositorio. El back-office Rails original sigue disponible en `/admin`.

## Requisitos
Node.js 22, npm, Ruby 3.3, Rails 8 y PostgreSQL 16.

## Desarrollo
Terminal 1, desde la raíz del repositorio:
```bash
bundle install
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails s -p 3000
```
Terminal 2:
```bash
cd frontend
npm install
npm start
```
Abrir http://localhost:4200. El proxy Angular redirige `/api` a Rails en localhost:3000.

## Funcionalidad
- Inicio y cierre de sesión por API Bearer, con token guardado en sessionStorage.
- Panel con indicadores calculados sobre datos reales.
- Listado y búsqueda de investigaciones.
- Alta de investigaciones (administradores); persistencia real y validación del servidor.
- Listado, búsqueda y detalle de evidencias.
- Consulta del historial inmutable de custodia de cada evidencia.
- Estados de carga, vacíos, errores HTTP, reintento y confirmación.
- Diseño responsive con controles etiquetados y accesibles mediante teclado.

## Contrato API
| Método | Ruta | Permisos | Respuesta |
| --- | --- | --- | --- |
| POST | /api/v1/login | Público | 201: token, token_type, expires_in |
| GET | /api/v1/me | Bearer | 200: id, name, role (`admin` o `analyst`) |
| DELETE | /api/v1/logout | Bearer | 204 |
| GET | /api/v1/cases | Bearer | 200: lista de casos |
| POST | /api/v1/cases | Bearer, admin | 201: caso; 422: errors |
| GET | /api/v1/evidences | Bearer | 200: lista con caso, tipo y custodio |
| GET | /api/v1/evidences/:id/custody_movements | Bearer | 200: evidence y custody_movements |

`POST /api/v1/login`: JSON `{"email":"demo@example.com","password":"..."}`. El token recibido se envía como `Authorization: Bearer <token>`. La contraseña no se persiste en el navegador.

`POST /api/v1/cases`: JSON `{"case":{"code":"CAS-2026-01","title":"Investigación","description":"Descripción","status":"open","opened_at":"2026-11-18"}}`. Campos obligatorios: code, title y opened_at; status admite `open` o `closed`. Las fechas usan ISO 8601 (YYYY-MM-DD). Código único.

Errores: 401 `{"error":"Token ausente, inválido o vencido"}`; 403 `{"error":"Permisos insuficientes"}`; 404 `{"error":"Recurso no encontrado"}`; 422 `{"errors":["..."]}`. Los errores de login son 401 `{"error":"Credenciales inválidas"}`.

## Compilación
```bash
cd frontend
npm run build
```
Los archivos compilados quedan en `dist/digital-custody/browser` (según configuración del builder).

## Pruebas automatizadas de interfaz
Las pruebas Playwright ejecutan Angular en un navegador Chromium y simulan la API para comprobar login, alta de casos, persistencia visual y manejo de errores HTTP. No sustituyen la demostración con Rails y PostgreSQL reales. Ejecutar `npx playwright install chromium` antes de `npm test`.

## Producción / Easypanel
El directorio `frontend/` incluye un Dockerfile multietapa y Caddy para servir Angular y reenviar `/api/*` a Rails por la red interna. En Easypanel crear un servicio Docker con contexto `frontend/`, puerto interno `80`, dominio `tp4.comercioflex.com.ar` y variable `RAILS_UPSTREAM=http://NOMBRE_SERVICIO_RAILS:3000` (usar el nombre real accesible desde la red del frontend). Configurar HTTPS en Easypanel. Caddy resuelve el fallback SPA a `index.html` y mantiene la API bajo el mismo origen, evitando CORS. **No exponer** PostgreSQL ni secretos Rails en Angular. Comprobar que Rails acepta el host reenviado y el proxy interno. El dominio es el destino previsto, **no** un despliegue ya realizado.

### Seguridad de datos demo
`db/seeds.rb` incluye credenciales de demostración públicas. **Nunca** ejecutar seeds de demo en producción ni reutilizar sus contraseñas. En un entorno de evaluación aislado, usar usuarios específicos con contraseñas nuevas y permisos mínimos.

## Demostración de entrega
1. Ingresar con un usuario administrador creado mediante seeds (consultar `db/seeds.rb`; nunca publicar contraseñas reales).
2. Mostrar dashboard y datos de casos y evidencias reales.
3. Crear un caso y verificar que aparezca tras recargar.
4. Abrir una evidencia y mostrar su cadena de custodia.
5. Intentar crear un caso con código duplicado y mostrar la validación 422.
6. Cerrar sesión y verificar que se solicita autenticación nuevamente.

## Verificación
```bash
bundle exec rails test
bundle exec rubocop
bundle exec brakeman
cd frontend && npm install && npm run build && npm test
```

### Integración con API real
En una base local aislada con seeds, iniciar Rails en 3000 y ejecutar `REAL_API=1 npx playwright test real-api.spec.ts` desde frontend. La prueba crea un caso con código único, recarga, verifica persistencia y el error 422, consulta historial y cierra sesión. Nunca ejecutar contra producción. El CI real-api prepara PostgreSQL 16 y Rails. En producción configurar `ADDITIONAL_APP_HOSTS=tp4.comercioflex.com.ar` en Rails si se conserva un APP_HOST administrativo distinto. Ver [guía TP2](../docs/DEPLOY_TP2.md).
