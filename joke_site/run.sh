#!/bin/sh
# Подставляет webhook_id из настроек аддона в конфиг nginx и запускает его.
ID="$(jq -r '.webhook_id // ""' /data/options.json)"

if [ -z "$ID" ]; then
  echo "webhook_id не задан в настройках аддона: статистика отправляться не будет"
  sed 's|proxy_pass http://homeassistant:8123/api/webhook/__WEBHOOK_ID__;|return 204;|' \
    /etc/nginx/nginx.conf.tpl > /etc/nginx/conf.d/default.conf
else
  sed "s|__WEBHOOK_ID__|$ID|" /etc/nginx/nginx.conf.tpl > /etc/nginx/conf.d/default.conf
fi

exec nginx -g 'daemon off;'
