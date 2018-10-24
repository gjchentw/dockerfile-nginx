FROM	gjchen/alpine:edge

RUN apk --no-cache --no-progress upgrade -f && \
	apk --no-cache --no-progress add nginx curl && \
	mkdir -p /etc/nginx/server.d && \
	curl --output /etc/nginx/modules/main.conf https://raw.githubusercontent.com/gjchentw/dockerfile-nginx/master/nginx-main.conf && \
	curl --output /etc/nginx/conf.d/00-http.conf https://raw.githubusercontent.com/gjchentw/dockerfile-nginx/master/nginx-http.conf && \
	curl --output /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/gjchentw/dockerfile-nginx/master/default.conf && \
	mkdir -p /var/log/nginx && \
	chmod 755 /var/log/nginx && \
	rm -f /var/log/nginx/* && \
	ln -s /dev/null /var/log/nginx/access.log && \
	ln -s /dev/null /var/log/nginx/error.log && \
	cd /etc/ssl && \
	openssl dhparam -out dh2048.pem 2048 && \
	mkdir -p .acme-challenges certs.d/default

ADD	s6.d /etc/s6.d

EXPOSE	80 443
