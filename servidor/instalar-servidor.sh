#!/usr/bin/env bash
#
# Installs the CT da Vila wger server on a fresh Ubuntu machine (e.g. Oracle
# Cloud "Always Free"), using the official wger docker setup plus Caddy for HTTPS.
#
# Usage, on the server:
#   curl -fsSL https://raw.githubusercontent.com/PatrickAgs/gym-app/master/servidor/instalar-servidor.sh | bash -s -- seu@email.com
#
# Without a DOMAIN variable the address is <ip>.sslip.io, a free name that
# points to the server's IP. Running the script again keeps the existing secrets.

set -euo pipefail

EMAIL="${1:?Uso: instalar-servidor.sh seu@email.com}"
IP="$(curl -fsS https://api.ipify.org)"
DOMAIN="${DOMAIN:-$(echo "$IP" | tr . -).sslip.io}"
DIR="$HOME/wger-docker"

echo "==> Servidor do CT da Vila em https://$DOMAIN"

echo "==> Instalando o Docker"
if ! command -v docker >/dev/null; then
    curl -fsSL https://get.docker.com | sudo sh
fi
sudo usermod -aG docker "$(whoami)"

echo "==> Liberando as portas 80 e 443 no firewall da máquina"
# Oracle's Ubuntu images reject everything except SSH with iptables
for port in 80 443; do
    if ! sudo iptables -C INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null; then
        sudo iptables -I INPUT 1 -p tcp --dport "$port" -j ACCEPT
    fi
done
if command -v netfilter-persistent >/dev/null; then
    sudo netfilter-persistent save
fi

echo "==> Baixando a configuração oficial do wger"
if [ ! -d "$DIR" ]; then
    git clone https://github.com/wger-project/docker "$DIR"
fi
cd "$DIR"

if [ ! -f config/.ct-da-vila ]; then
    echo "==> Gerando senhas e chaves"
    secret_key="$(openssl rand -hex 32)"
    db_pass="$(openssl rand -hex 16)"
    ps_pass="$(openssl rand -hex 16)"
    flower_pass="$(openssl rand -hex 16)"
    jwt_keys="$(python3 - <<'EOF'
import base64, json, re, subprocess
pem = subprocess.run(['openssl', 'genpkey', '-algorithm', 'RSA', '-pkeyopt', 'rsa_keygen_bits:2048'],
                     capture_output=True, check=True).stdout
dump = subprocess.run(['openssl', 'pkey', '-text', '-noout'], input=pem,
                      capture_output=True, check=True).stdout.decode()
def field(name):
    m = re.search(name + r':\s*\n((?:\s+[0-9a-f:]+\n)+)', dump)
    return int(m.group(1).replace(':', '').replace(' ', '').replace('\n', ''), 16)
def b64(i):
    return base64.urlsafe_b64encode(i.to_bytes((i.bit_length() + 7) // 8, 'big')).decode().rstrip('=')
parts = dict(n='modulus', d='privateExponent', p='prime1', q='prime2',
             dp='exponent1', dq='exponent2', qi='coefficient')
priv = {'kty': 'RSA', 'alg': 'RS256', 'kid': 'wger', 'e': 'AQAB'}
priv.update({k: b64(field(v)) for k, v in parts.items()})
pub = {k: priv[k] for k in ('kty', 'n', 'e', 'alg', 'kid')}
enc = lambda d: base64.urlsafe_b64encode(json.dumps(d).encode()).decode()
print('JWT_PRIVATE_KEY=' + enc(priv))
print('JWT_PUBLIC_KEY=' + enc(pub))
EOF
)"

    set_env() {
        local key="$1" value="$2"
        sed -i "/^${key}=/d" config/prod.env
        echo "${key}=${value}" >> config/prod.env
    }
    set_env SECRET_KEY "$secret_key"
    set_env SITE_URL "https://$DOMAIN"
    set_env CSRF_TRUSTED_ORIGINS "https://$DOMAIN"
    set_env X_FORWARDED_PROTO_HEADER_SET True
    set_env TIME_ZONE America/Sao_Paulo
    set_env TZ America/Sao_Paulo
    set_env POSTGRES_PASSWORD "$db_pass"
    set_env PS_DATABASE_URI "postgres://wger:$db_pass@db:5432/wger"
    set_env PS_STORAGE_PG_URI "postgres://powersync_storage:$ps_pass@db:5432/wger"
    set_env CELERY_FLOWER_PASSWORD "$flower_pass"
    # Students are registered by the gym, not by themselves
    set_env ALLOW_REGISTRATION False
    set_env FROM_EMAIL "CT da Vila <$EMAIL>"
    while IFS= read -r line; do
        set_env "${line%%=*}" "${line#*=}"
    done <<< "$jwt_keys"

    touch config/.ct-da-vila
fi

echo "==> Configurando o HTTPS (Caddy)"
cat > config/Caddyfile <<EOF
$DOMAIN {
    tls $EMAIL
    encode

    handle /static/* {
        root * /wger
        header Cache-Control "public, max-age=31536000, immutable"
        file_server
    }

    handle /media/* {
        root * /wger
        file_server
    }

    # PowerSync, used by the app to sync and work offline
    handle_path /ps/* {
        reverse_proxy powersync:8080
    }

    reverse_proxy web:8000 {
        lb_try_duration 5s
        header_up X-Forwarded-Proto {scheme}
    }
}
EOF

cat > docker-compose.override.yml <<'EOF'
services:
  caddy:
    image: docker.io/caddy:2
    restart: unless-stopped
    depends_on:
      - web
      - powersync
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./config/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy-data:/data
      - caddy-config:/config
      - static:/wger/static:ro
      - media:/wger/media:ro

  # Caddy answers on 80/443 instead
  nginx:
    ports: !reset []

volumes:
  caddy-data:
  caddy-config:
EOF

echo "==> Subindo o servidor (a primeira vez demora uns 10 minutos)"
sudo docker compose pull
sudo docker compose up -d

echo "==> Esperando o servidor ficar pronto"
until sudo docker compose exec -T web wget -q -O /dev/null http://localhost:8000/api/v2/version/ 2>/dev/null; do
    sleep 10
done
sudo docker compose exec -T web ./manage.py setup-powersync-storage
sudo docker compose exec -T web ./manage.py set-site-url
sudo docker compose restart powersync

echo
echo "Pronto! Abra https://$DOMAIN"
echo "Usuário: admin   Senha: adminadmin   (troque a senha no primeiro acesso)"
