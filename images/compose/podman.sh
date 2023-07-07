#!/bin/bash
podman network create pulpnet

podman pod create --name postgres -p 5432:5432 --network pulpnet
podman pod create --name redis -p 6379 --network pulpnet
podman pod create --name pulp-content -p 24816:24816 --network pulpnet
podman pod create --name pulp-api -p 24817:24817 --network pulpnet
podman pod create --name pulp-web -p 8080:8080 --network pulpnet
podman pod create --name pulp-worker --network pulpnet

podman volume create pulpvol
podman volume create pg_data
podman volume create redis_data

podman run --pod postgres -d --name pulp-postgres -v "pg_data:/var/lib/postgresql" -e POSTGRES_USER=pulp -e POSTGRES_PASSWORD=password -e POSTGRES_DB=pulp -e POSTGRES_INITDB_ARGS='--auth-host=scram-sha-256' -e POSTGRES_HOST_AUTH_METHOD='scram-sha-256' docker.io/library/postgres:13
podman run --pod redis -d --name pulp_redis -v "redis_data:/data"  docker.io/library/redis:latest
podman run --pod pulp-web -d --name pulp_web -v "./assets/bin/nginx.sh:/usr/bin/nginx.sh:Z" -v "./assets/nginx/nginx.conf.template:/etc/opt/rh/rh-nginx116/nginx/nginx.conf.template:Z" quay.io/pulp/pulp-web:latest
podman run --pod pulp-api -d --name pulp_api -e POSTGRES_SERVICE_PORT=5432 -e POSTGRES_SERVICE_HOST=postgres -e PULP_ADMIN_PASSWORD=password -v "./assets/settings.py:/etc/pulp/settings.py:z" -v "./assets/certs:/etc/pulp/certs:z" -v "pulpvol:/var/lib/pulp" quay.io/pulp/pulp-minimal:latest pulp-api
podman run --pod pulp-content -d --name pulp_content -e POSTGRES_SERVICE_PORT=5432 -e POSTGRES_SERVICE_HOST=postgres -e PULP_ADMIN_PASSWORD=password -v "./assets/settings.py:/etc/pulp/settings.py:z" -v "./assets/certs:/etc/pulp/certs:z" -v "pulpvol:/var/lib/pulp" quay.io/pulp/pulp-minimal:latest pulp-content
podman run --pod pulp-worker -d --name pulp_worker -e POSTGRES_SERVICE_PORT=5432 -e POSTGRES_SERVICE_HOST=postgres -e PULP_ADMIN_PASSWORD=password -v "./assets/settings.py:/etc/pulp/settings.py:z" -v "./assets/certs:/etc/pulp/certs:z" -v "pulpvol:/var/lib/pulp" quay.io/pulp/pulp-minimal:latest pulp-worker
