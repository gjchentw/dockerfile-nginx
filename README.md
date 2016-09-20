# gjchen/nginx@Dockerhub
Alpine Linux with nginx configured for public web services.
* Base docker image: https://hub.docker.com/r/gjchen/alpine/
* HSTS ready.
* Get SSL certificates from Let's Encrypt ( use https://github.com/lukas2511/dehydrated ) and auto-renew via crond.

# Running Nginx Service Docker Swarm Mode
Use virtual.host.com.conf (), with default/self-signed certs:
```
docker service create --name nginx --replicas 1 -p 80:80 -p 443:443 --mount type=bind,source=$(pwd)/certs/virtual.host.com,target=/etc/ssl/certs/virtual.host.com --mount type=bind,source=$(pwd)/virtual.host.com.conf,target=/etc/nginx/conf.d/virtual.host.com.conf gjchen/nginx
``` 

# Let's Encrypt
Put your domain in /etc/ssl/domains.txt:
```
echo virtual.host.com >> /etc/ssl/domains.txt
```

Get certificates manually:
```
/etc/ssl/dehydrated -c --ocsp
```

Auto renew weekly by /etc/crontabs/root (inspired by gslin https://letsencrypt.tw/ ) :
```
0 0 * * * sleep $(expr $(printf "\%d" "0x$(hostname | md5sum | cut -c 1-8)") \% 86400);/etc/ssl/dehydrated -c --ocsp; nginx -s reload
```

* PS. If have multiple replicas of gjchen/nginx, provide shared mounts /etc/ssl/.acme-challenges for challenges.
