FROM	gjchen/alpine:latest

RUN 	echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
	apk --no-cache --no-progress upgrade -f && \
	apk --no-cache --no-progress add nginx git && \
	mkdir -p /etc/nginx/local /etc/nginx/ssk_keys

ADD	nginx-main.conf /etc/nginx/modules/main.conf
ADD	nginx-http.conf	/etc/nginx/conf.d/00-http.conf

ADD	https://github.com/lukas2511/dehydrated /opt/letsencrypt.sh

WORKDIR	/etc/nginx/
RUN	openssl req -nodes -newkey rsa:2048 -keyout local/localhost.key -out local/localhost.csr -subj "/C=TW/ST=Taiwan/L=Taipei/O=unknown/OU=IT/CN=localhost.localdomain"
RUN	openssl x509 -req -days 1800 -in local/localhost.csr -signkey local/localhost.key -out local/localhost.crt
RUN	openssl dhparam -out dh2048.pem 2048

VOLUME	[ /etc/nginx/ssk_keys ]

EXPOSE	80 443
CMD	rsyslogd; crond -b; nginx -g "daemon off;";
