FROM	gjchen/alpine:latest

RUN 	echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
	apk --no-cache --no-progress upgrade -f && \
	apk --no-cache --no-progress add nginx curl

ADD	nginx-main.conf /etc/nginx/modules/main.conf
ADD	nginx-http.conf	/etc/nginx/conf.d/00-http.conf
ADD	https://raw.githubusercontent.com/lukas2511/dehydrated/v0.3.1/dehydrated /etc/ssl/

# You may want recreate private key
RUN	openssl req -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=TW/ST=Taiwan/L=Taipei/O=unknown/OU=IT/CN=localhost.localdomain" && \
	openssl x509 -req -days 1800 -in localhost.csr -signkey localhost.key -out localhost.crt && \
	openssl dhparam -out dh2048.pem 2048

# support Lets Encrypt, renew automatically
RUN	cd /etc/ssl && \
	mkdir .acme-challenges && \
	openssl req -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=TW/ST=Taiwan/L=Taipei/O=unknown/OU=IT/CN=localhost.localdomain" && \
	openssl x509 -req -days 1800 -in localhost.csr -signkey localhost.key -out localhost.crt && \
	openssl dhparam -out dh2048.pem 2048 && \
	chmod a+x dehydrated && echo "WELLKNOWN=/etc/ssl/.acme-challenges" > config && \
	echo '0 0 * * * sleep $(expr $(printf "\%d" "0x$(hostname | md5sum | cut -c 1-8)") \% 86400);/etc/ssl/dehydrated -c --ocsp; nginx -s reload' >> /etc/crontabs/root

VOLUME	[ "/etc/nginx/conf.d", "/etc/ssl/.acme-challenges" ]

EXPOSE	80 443
CMD	rsyslogd; crond -b; nginx -g "daemon off;";
