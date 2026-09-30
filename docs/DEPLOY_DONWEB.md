# Deploy temporal en Donweb

Esta guía deja Digital Custody publicado en un subdominio con Rails + Puma + PostgreSQL + Nginx. Está pensada para una entrega temporal y para poder retirarla después sin afectar otras aplicaciones del servidor.

## 1. DNS

Crear un registro `A` para el subdominio elegido apuntando a la IPv4 del Cloud de Donweb.

Ejemplo:

```text
digitalcustody.tudominio.com -> IP_DEL_SERVIDOR
```

## 2. Preparar el servidor

Conectarse por SSH e instalar solamente lo necesario si todavía no está instalado:

```bash
sudo apt update
sudo apt install -y git ruby-full build-essential libpq-dev postgresql nginx certbot python3-certbot-nginx
sudo gem install bundler
```

Comprobar:

```bash
ruby -v
bundle -v
psql --version
nginx -v
```

## 3. Usuario y carpeta de la aplicación

Se recomienda ejecutar la aplicación con un usuario separado llamado `deploy`:

```bash
sudo adduser --disabled-password --gecos "" deploy
sudo mkdir -p /var/www/digital-custody
sudo chown -R deploy:deploy /var/www/digital-custody
```

Clonar el repositorio:

```bash
sudo -u deploy git clone https://github.com/nachoechave/programacion4-trabajo.git /var/www/digital-custody
cd /var/www/digital-custody
sudo -u deploy bundle install
```

## 4. Base PostgreSQL separada

Elegir una contraseña segura y reemplazar `CLAVE_SEGURA`:

```bash
sudo -u postgres psql -c "CREATE USER digital_custody WITH PASSWORD 'CLAVE_SEGURA';"
sudo -u postgres psql -c "CREATE DATABASE digital_custody_production OWNER digital_custody;"
```

## 5. Variables de entorno

Generar una clave para Rails:

```bash
cd /var/www/digital-custody
sudo -u deploy bundle exec rails secret
```

Copiar `deploy/digital-custody.env.example` a `/etc/digital-custody.env` y completar:

```bash
sudo cp deploy/digital-custody.env.example /etc/digital-custody.env
sudo nano /etc/digital-custody.env
sudo chmod 600 /etc/digital-custody.env
```

Reemplazar como mínimo:

```text
APP_HOST=digitalcustody.tudominio.com
SECRET_KEY_BASE=CLAVE_GENERADA_CON_RAILS_SECRET
DATABASE_URL=postgresql://digital_custody:CLAVE_SEGURA@127.0.0.1/digital_custody_production
```

No subir `/etc/digital-custody.env` a GitHub.

## 6. Preparar Rails

```bash
cd /var/www/digital-custody
sudo -u deploy bash -c 'set -a; source /etc/digital-custody.env; set +a; bundle exec rails db:prepare'
sudo -u deploy bash -c 'set -a; source /etc/digital-custody.env; set +a; bundle exec rails assets:precompile'
```

Para cargar los datos de demostración:

```bash
sudo -u deploy bash -c 'set -a; source /etc/digital-custody.env; set +a; bundle exec rails db:seed'
```

## 7. Servicio Puma

```bash
sudo cp deploy/digital-custody.service.example /etc/systemd/system/digital-custody.service
sudo systemctl daemon-reload
sudo systemctl enable --now digital-custody
sudo systemctl status digital-custody
```

Si el servicio no encuentra `bundle` porque Ruby fue instalado con rbenv/asdf, ajustar `ExecStart` con la ruta de Bundler de ese servidor.

Probar Puma localmente:

```bash
curl http://127.0.0.1:3001/up
```

Debe responder correctamente antes de seguir con Nginx.

## 8. Nginx

Copiar el ejemplo y reemplazar el dominio:

```bash
sudo cp deploy/nginx-digital-custody.conf.example /etc/nginx/sites-available/digital-custody
sudo nano /etc/nginx/sites-available/digital-custody
sudo ln -s /etc/nginx/sites-available/digital-custody /etc/nginx/sites-enabled/digital-custody
sudo nginx -t
sudo systemctl reload nginx
```

## 9. HTTPS

Cuando el DNS ya resuelva al servidor:

```bash
sudo certbot --nginx -d digitalcustody.tudominio.com
```

Abrir:

```text
https://digitalcustody.tudominio.com/admin/login
```

## 10. Actualizar el proyecto durante la entrega

```bash
cd /var/www/digital-custody
sudo -u deploy git pull
sudo -u deploy bundle install
sudo -u deploy bash -c 'set -a; source /etc/digital-custody.env; set +a; bundle exec rails db:migrate'
sudo -u deploy bash -c 'set -a; source /etc/digital-custody.env; set +a; bundle exec rails assets:precompile'
sudo systemctl restart digital-custody
```

## 11. Bajarlo después de la entrega

```bash
sudo systemctl disable --now digital-custody
sudo rm -f /etc/nginx/sites-enabled/digital-custody
sudo nginx -t
sudo systemctl reload nginx
```

Después eliminar el registro DNS del subdominio. La base y `/var/www/digital-custody` se pueden conservar unos días como respaldo y borrar más adelante.

## Diagnóstico rápido

```bash
sudo systemctl status digital-custody
sudo journalctl -u digital-custody -n 100 --no-pager
sudo nginx -t
curl http://127.0.0.1:3001/up
```
