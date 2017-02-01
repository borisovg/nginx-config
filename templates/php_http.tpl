location ~ \.php$ {
    try_files $uri =404;

    fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

    include fastcgi_params;

    # LOCAL php_http_tpl #
}