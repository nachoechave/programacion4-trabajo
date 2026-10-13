# Deploy de Digital Custody en Easypanel

Guía de despliegue independiente para la entrega de Programación 4. El proveedor de hosting se define al momento de publicar.

1. Crear una instancia PostgreSQL exclusiva para Digital Custody (preferentemente PostgreSQL 16, que es la versión documentada para el proyecto).
2. Crear una aplicación Docker desde la raíz del repositorio, puerto 3000.
3. Asignar un dominio o subdominio propio de Digital Custody con HTTPS.
4. Configurar las variables `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `RAILS_ENV=production`, `APP_HOST` (solo hostname, sin esquema) y `SECRET_KEY_BASE`. La aplicación usa variables `DB_*` en producción, no depende de `DATABASE_URL`. Generar el secreto con `bundle exec rails secret` y mantenerlo fuera de Git.
5. Montar un volumen **persistente** sobre `/app/storage` y comprobarlo mediante subida, redeploy y nueva descarga del mismo adjunto. Respaldar también PostgreSQL.
6. Ejecutar antes de iniciar: bundle exec rails db:prepare.
7. Iniciar: bundle exec rails server -b 0.0.0.0 -p 3000.
8. Configurar el dominio de Easypanel para dirigir HTTPS al **puerto interno 3000** (no 80). Comprobar `GET /up`, login administrativo, subida/descarga de adjuntos, token de API y persistencia entre redeploys.

La configuración SMTP es opcional: SMTP_ADDRESS, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, SMTP_DOMAIN, MAIL_FROM.

No ejecutar db:seed automáticamente en producción: incorpora cuentas de demostración con claves conocidas. No publicar secretos ni reutilizar bases de datos de otras aplicaciones.

El código de esta rama no representa un despliegue real. Para compartir la URL pública, primero hay que completar la configuración de Easypanel y comprobar los servicios.

## Primer administrador de producción

Los datos demo se bloquean en producción. Después de crear la base, abrir una consola dentro del contenedor de Digital Custody:

```bash
bundle exec rails console
```

Crear el usuario con un email real y una contraseña robusta, sin colocar la contraseña en Git ni en el historial de comandos:

```ruby
require "io/console"
password = STDIN.noecho(&:gets).chomp
User.create!(name: "Administrador", email: "admin@tu-dominio", password: password, role: :admin, active: true)
```

No reutilizar las cuentas de demostración de desarrollo. Comprobar el inicio de sesión, y mantener secretos y backups fuera del repositorio.

## Estado conocido de la instancia (13/10/2026)

Según la verificación realizada durante la puesta en marcha, la aplicación y PostgreSQL se encuentran desplegados en servicios separados de Easypanel, el login público carga correctamente y se creó un administrador desde Rails console. Queda por validar la persistencia del volumen `/app/storage` y las pruebas funcionales completas; no se presume que hayan pasado solo por ver los servicios encendidos. La URL exacta y las credenciales no se guardan en el repositorio.
