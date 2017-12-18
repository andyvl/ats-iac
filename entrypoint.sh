#!/bin/bash

set -e 

export DOLAR=$
NGINX_SITES_ENABLED=/etc/nginx/sites-enabled
[[ -d ${NGINX_SITES_ENABLED} ]] || mkdir -p ${NGINX_SITES_ENABLED}

envsubst < /tmp/nginx-config-templates/nats.template > ${NGINX_SITES_ENABLED}/${NATS_SERVER_NAME} &&
envsubst < /tmp/nginx-config-templates/sb.template > ${NGINX_SITES_ENABLED}/${SB_SERVER_NAME} &&
nginx-debug -g 'daemon off;'


#/bin/bash -c "envsubst < /tmp/nginx-config-templates/ats.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"