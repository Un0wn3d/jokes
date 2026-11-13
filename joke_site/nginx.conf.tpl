limit_req_zone $server_name zone=hook:1m rate=30r/s;

# IP-адреса в логи намеренно не пишем.
log_format site '$time_iso8601 [site] "$request" -> $status';
log_format hook '$time_iso8601 [hook] $request_method -> $status (ответ HA: $upstream_status) тело: $request_body';

server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    server_tokens off;

    error_log /dev/stderr __LOG_LEVEL__;
    access_log __ACCESS_SITE__;

    # Единственная «дверь» к Home Assistant: только POST и только в один вебхук
    location = /hook {
        access_log __ACCESS_HOOK__;
        limit_except POST { deny all; }
        limit_req zone=hook burst=60 nodelay;
        client_max_body_size 4k;

        proxy_pass http://homeassistant:8123/api/webhook/__WEBHOOK_ID__;
        proxy_set_header Host homeassistant:8123;
        # убираем заголовки Cloudflare, чтобы HA считал запрос внутренним
        proxy_set_header X-Forwarded-For "";
        proxy_set_header X-Forwarded-Host "";
        proxy_set_header X-Forwarded-Proto "";
        proxy_set_header X-Real-IP "";
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
