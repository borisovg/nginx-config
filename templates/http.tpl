server {

listen %%IP%%:%%HTTP_PORT%%;
server_name %%DOMAIN%% www.%%DOMAIN%%;

access_log /var/log/nginx/%%DOMAIN%%-access.log;
error_log /var/log/nginx/%%DOMAIN%%-error.log;

index %%INDEX%%;

root /srv/www/%%DOMAIN%%;

server_tokens off;

location ~ /\.ht {
	deny all;
}

location = /favicon.ico {
	access_log off;
	log_not_found off;
}

# LOCAL http_tpl #

}
