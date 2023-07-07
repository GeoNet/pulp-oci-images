#!/bin/bash
podman network create pulpnet

podman volume create pulpvol
podman volume create pulpcont
podman volume create pg_data
podman volume create redis_data

podman pod create --name pulp-aio -p 8080:8080 --network pulpnet

# "CONTENT_ORIGIN='http://$(hostname):8080'
# ANSIBLE_API_HOSTNAME='http://$(hostname):8080'
# ANSIBLE_CONTENT_HOSTNAME='http://$(hostname):8080/pulp/content'
# CACHE_ENABLED=True" >> settings/settings.py

podman run --detach \
            --pod pulp-aio \
             --name pulp \
             --volume "/etc/pulp/assets:/etc/pulp:Z" \
             --volume "pulpvol:/var/lib/pulp:Z" \
             --volume "pg_data:/var/lib/postgresql:Z" \
             --volume "pulpcont:/var/lib/containers:Z" \
             quay.io/pulp/pulp
