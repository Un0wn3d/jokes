#!/bin/sh
# Читает настройки аддона, собирает конфиг nginx и запускает его.
OPTS=/data/options.json
ID="$(jq -r '.webhook_id // ""' $OPTS)"
LEVEL="$(jq -r '.log_level // "info"' $OPTS)"
LOGREQ="$(jq -r 'if .log_requests == false then "false" else "true" end' $OPTS)"

if [ "$LOGREQ" = "true" ]; then
  ACC_SITE="/dev/stdout site"
  ACC_HOOK="/dev/stdout hook"
else
  ACC_SITE="off"
  ACC_HOOK="off"
fi

echo "[joke_site] запуск: log_level=$LEVEL, журнал запросов=$LOGREQ"

TPL=/etc/nginx/nginx.conf.tpl
OUT=/etc/nginx/conf.d/default.conf

if [ -z "$ID" ]; then
  echo "[joke_site] ВНИМАНИЕ: webhook_id не задан в настройках аддона, статистика отправляться не будет"
  sed -e 's|proxy_pass http://homeassistant:8123/api/webhook/__WEBHOOK_ID__;|return 204;|' $TPL > $OUT.tmp
else
  echo "[joke_site] вебхук настроен (id из ${#ID} символов)"
  sed -e "s|__WEBHOOK_ID__|$ID|" $TPL > $OUT.tmp
fi

sed -e "s|__LOG_LEVEL__|$LEVEL|" \
    -e "s|__ACCESS_SITE__|$ACC_SITE|" \
    -e "s|__ACCESS_HOOK__|$ACC_HOOK|" $OUT.tmp > $OUT
rm -f $OUT.tmp

nginx -t || { echo "[joke_site] ОШИБКА: конфиг nginx некорректен"; exit 1; }
exec nginx -g 'daemon off;'
