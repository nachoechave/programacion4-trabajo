# Digital Custody

Digital Custody es una aplicación web académica para registrar casos de análisis informático, administrar evidencias digitales y mantener una cadena de custodia trazable.

## Problema que resuelve

En una investigación informática es necesario conocer qué evidencia existe, a qué caso pertenece, quién es su custodio actual y conservar el historial completo de transferencias. La aplicación registra cada cambio de custodia como un movimiento auditable que no puede editarse ni eliminarse desde el back-office.

## Arquitectura

Es una aplicación monolítica de Ruby on Rails. El back-office utiliza controladores Rails y vistas ERB. Active Record concentra la persistencia y las reglas del dominio; PostgreSQL mantiene claves foráneas, restricciones e índices. La transferencia se encapsula en `EvidenceTransferService` y se ejecuta dentro de una transacción.

## Tecnologías

- Ruby 3.3.12
- Ruby on Rails 8.1.3.1
- PostgreSQL 16
- Active Record
- ERB y CSS
- Minitest

El desarrollo local se realiza en Ubuntu 24.04 mediante WSL 2.

## Modelos y relaciones

- `User`: administrador o analista.
- `Case`: investigación con analistas y evidencias.
- `CaseAssignment`: asignación de un analista a un caso.
- `EvidenceType`: catálogo de tipos de evidencia.
- `Evidence`: evidencia con un custodio actual.
- `CustodyMovement`: registro inmutable de una asignación o transferencia.

```mermaid
erDiagram
    USER ||--o{ CASE_ASSIGNMENT : recibe
    CASE ||--o{ CASE_ASSIGNMENT : incluye
    CASE ||--o{ EVIDENCE : contiene
    EVIDENCE_TYPE ||--o{ EVIDENCE : clasifica
    USER ||--o{ EVIDENCE : custodia
    EVIDENCE ||--|{ CUSTODY_MOVEMENT : registra
    USER o|--o{ CUSTODY_MOVEMENT : origen
    USER ||--o{ CUSTODY_MOVEMENT : destino
    USER ||--o{ CUSTODY_MOVEMENT : ejecuta
```

## Instalación y ejecución

Desde PowerShell, ingresar a Ubuntu:

```powershell
wsl -d Ubuntu
```

Dentro de Ubuntu:

```bash
cd /mnt/c/UTN/programacion4/trabajo
sudo pg_ctlcluster 16 main start
bundle install
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails server
```

Abrir `http://localhost:3000/admin/login`.

## Rutas principales

| Ruta | Función |
| --- | --- |
| `/admin/login` | Ingreso administrativo |
| `/admin` | Dashboard |
| `/admin/cases` | Casos |
| `/admin/evidences` | Evidencias |
| `/admin/evidence_types` | Tipos de evidencia |
| `/admin/users` | Usuarios |
| `/admin/custody_movements` | Historial de custodia |
| `/api/v1/cases` | Consulta JSON de casos |
| `/api/v1/evidences` | Consulta JSON de evidencias |

La API requiere autenticación mediante Bearer token. Se obtiene con `POST /api/v1/login` enviando `email` y `password` en JSON. El token vence a las 24 horas y se revoca con `DELETE /api/v1/logout`. La creación de casos por API requiere rol administrador.

## Testing

```bash
bundle exec rails test
```

Los tests principales cubren validaciones únicas, autenticación administrativa, registro inicial y las reglas transaccionales de transferencia de custodia.

## Estado del proyecto

Implementado:

- modelos y migraciones PostgreSQL;
- autenticación administrativa mediante sesión;
- back-office con dashboard;
- gestión de casos, evidencias, tipos y usuarios;
- registro inicial de custodia;
- historial de cadena de custodia;
- transferencia transaccional de evidencias;
- seeds idempotentes para la demostración;
- tests principales;
- API JSON de consulta para casos y evidencias con autenticación Bearer.

Funcionalidades incorporadas en la finalización:

- autenticación de la API mediante tokens Bearer;
- archivos adjuntos mediante Active Storage;
- notificaciones Action Mailer de transferencias cuando se configura SMTP;
- controles RuboCop y Brakeman en CI;
- pruebas automatizadas adicionales.

## Despliegue de demostración (octubre de 2026)

La aplicación fue desplegada en una instancia independiente de Easypanel, con PostgreSQL exclusivo. Se confirmó el acceso a la pantalla de login en producción y la creación de un usuario administrador mediante Rails console. El correo del administrador de demostración es `admin@digitalcustody.com.ar`. **Su contraseña no se publica en GitHub**: se configura de manera privada, debe rotarse si ha sido compartida y no debe incluirse en README, seeds ni historial de commits. El dominio de la instancia se gestiona fuera del repositorio. Consultar `docs/DEPLOY_EASYPANEL.md` para los pasos de instalación.

**Verificaciones pendientes antes de dar por validada la instancia:** comprobar que `/app/storage` utiliza un volumen persistente y que los archivos adjuntos sobreviven a un redeploy; probar subida y descarga; confirmar `GET /up`, API autenticada y el resultado vigente de CI. El despliegue operativo no implica por sí solo que estas verificaciones se hayan completado.

**Datos de demostración:** los seeds de desarrollo contienen usuarios ficticios y contraseñas conocidas; no ejecutarlos en producción sin revisar su finalidad. Cualquier expediente judicial simulado debe identificarse expresamente como académico y no representar actuaciones reales.
