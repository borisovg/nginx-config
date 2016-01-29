server {

listen %%IP%%%%HTTPS_PORT%% ssl;
server_name %%DOMAIN%%

ssl on;
ssl_certificate ssl/%%DOMAIN%%.pem;
ssl_certificate_key ssl.private/%%DOMAIN%%.pem;
ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
ssl_dhparam /etc/ssl/dhparam.pem;
ssl_prefer_server_ciphers on;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_session_cache builtin:1000 shared:SSL:10m;
ssl_session_timeout 10m;

access_log /var/log/nginx/%%DOMAIN%%-access.log;
error_log /var/log/nginx/%%DOMAIN%%-error.log;

index %%INDEX%%;

root %%ROOT%%;

server_tokens off;

location ~ /\.ht {
	deny all;
}

location = /favicon.ico {
	access_log off;
	log_not_found off;
}

# LOCAL https_tpl #

}
