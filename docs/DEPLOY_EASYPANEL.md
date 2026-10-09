# Deploy de Digital Custody en Easypanel

Implementación prevista para el servidor Donweb, independiente de ComercioFlex.

1. Crear una instancia PostgreSQL 16 exclusiva para Digital Custody.
2. Crear una aplicación Docker desde la raíz del repositorio, puerto 3000.
3. Asignar un subdominio (por ejemplo, digitalcustody.comercioflex.com.ar) con HTTPS.
4. Configurar las variables DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, RAILS_ENV=production, APP_HOST y SECRET_KEY_BASE.
5. Montar un volumen **persistente** sobre /app/storage. Respaldar también PostgreSQL.
6. Ejecutar antes de iniciar: bundle exec rails db:prepare.
7. Iniciar: bundle exec rails server -b 0.0.0.0 -p 3000.
8. Comprobar GET /up, login administrativo, subida/descarga de adjuntos, token de API y persistencia entre redeploys.

La configuración SMTP es opcional: SMTP_ADDRESS, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, SMTP_DOMAIN, MAIL_FROM.

No ejecutar db:seed automáticamente en producción: incorpora cuentas de demostración con claves conocidas. No publicar secretos ni conectar el sistema a la base de datos de ComercioFlex.

El código de esta rama no representa un despliegue real. Para compartir la URL pública, primero hay que completar la configuración de Easypanel y comprobar los servicios.
