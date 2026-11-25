# Publicación del TP2 en Easypanel

1. Conservar el servicio Rails y PostgreSQL existentes, dentro del mismo proyecto/red. Respaldar base y storage. Actualizar Rails desde main después de aprobar el PR; puerto interno 3000.
2. Mantener APP_HOST del back-office y agregar ADDITIONAL_APP_HOSTS=tp4.comercioflex.com.ar. No reemplazar secretos ni credenciales existentes. Ejecutar db:prepare según el procedimiento habitual.
3. Crear aplicación frontend Docker, repositorio nachoechave/programacion4-trabajo, rama main, contexto frontend (Dockerfile relativo al contexto: Dockerfile). Puerto interno 80.
4. Definir RAILS_UPSTREAM=http://NOMBRE_INTERNO_REAL_DE_RAILS:3000 (nombre de servicio comprobado en Easypanel, no un dominio público).
5. Agregar dominio tp4.comercioflex.com.ar con HTTPS, apuntando al puerto 80; crear DNS hacia el servidor según el proveedor. Caddy sirve Angular y reenvía /api/* sin cambiar el prefijo.
6. Verificar /up en el backend, login administrativo y login Angular, crear un caso de prueba, recargar, probar duplicado, consultar historial y cerrar sesión. Verificar también que un analista no pueda crear casos.
7. No activar ALLOW_DEMO_SEEDS en producción. Usar usuarios de evaluación con contraseñas nuevas, no secretos en Git. No exponer PostgreSQL.

Si hay 403 de host, revisar ADDITIONAL_APP_HOSTS; si hay 502, revisar DNS interno, puerto y estado de Rails. Si hay 401, comprobar usuario activo y credenciales. La publicación no se considera hecha hasta comprobarla.
