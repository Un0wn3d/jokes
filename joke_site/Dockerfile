FROM nginx:alpine
RUN apk add --no-cache jq
COPY nginx.conf.tpl /etc/nginx/nginx.conf.tpl
COPY run.sh /run.sh
COPY site/ /usr/share/nginx/html/
RUN sed -i 's/\r$//' /run.sh && chmod +x /run.sh
CMD ["/run.sh"]
