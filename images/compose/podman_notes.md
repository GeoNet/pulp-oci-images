# notes

the pulp-web container gives me a 403 error for some reason maybe basic auth is needed ?
I can use the pulp api container on my localhost with the api port 24817

datadog uses sha1 checksums which have to be allowed in the environment or settings.py file

## example pulp cli.toml

```toml
[cli]
base_url = "http://localhost:24817"
api_root = "/pulp/"
domain = "default"
username = "admin"
password = "password"
cert = ""
key = ""
verify_ssl = false
format = "json"
dry_run = false
timeout = 20
verbose = 0
```

## example commands to sync datadog v7 rpms

`pulp rpm remote create --name datadog --url https://yum.datadoghq.com/stable/7/x86_64/`

`pulp rpm repository create --name datadog_7 --remote datadog`

`pulp rpm repository sync --name datadog_7 --sync-policy mirror_content_only`

wait for sync to finish

`pulp rpm publication create --repository datadog_7`

`pulp rpm publication list --repository datadog_7`

`pulp rpm distribution create --name datadog7 --base-path datadog7 --publication {HREF}` ^href from above command output

```plain
[mossc@hutl24060 ~]$ pulp rpm publication create --repository datadog_7
Started background task /pulp/api/v3/tasks/0188993c-d9ee-776a-b7e8-a843ea6c776b/
.......Done.
{
  "pulp_href": "/pulp/api/v3/publications/rpm/rpm/0188993c-da3d-7825-8067-f1e975c33478/",
  "pulp_created": "2023-06-08T04:21:22.110477Z",
  "repository_version": "/pulp/api/v3/repositories/rpm/rpm/018898ba-485e-790d-8ca5-b82856dd4c83/versions/1/",
  "repository": "/pulp/api/v3/repositories/rpm/rpm/018898ba-485e-790d-8ca5-b82856dd4c83/",
  "metadata_checksum_type": "sha256",
  "package_checksum_type": "sha256",
  "gpgcheck": 0,
  "repo_gpgcheck": 0,
  "sqlite_metadata": false
}

```

create distribution (repo for other servers to consume)

```
[mossc@hutl24060 ~]$ pulp rpm distribution create --name datadog7 --base-path datadog7 --publication /pulp/api/v3/publications/rpm/rpm/0188993c-da3d-7825-8067-f1e975c33478/
Started background task /pulp/api/v3/tasks/01889942-0127-7f7c-b6d3-c46515ce7d7d/
Done.
{
  "pulp_href": "/pulp/api/v3/distributions/rpm/rpm/01889942-021d-737a-863d-cf19ece6ca8d/",
  "pulp_created": "2023-06-08T04:26:59.997791Z",
  "base_path": "datadog7",
  "base_url": "http://pulp_content:24816/pulp/content/datadog7/",
  "content_guard": null,
  "pulp_labels": {},
  "name": "datadog7",
  "repository": null,
  "publication": "/pulp/api/v3/publications/rpm/rpm/0188993c-da3d-7825-8067-f1e975c33478/"
}
```

then you can curl the repo file

`curl http://localhost:24816/pulp/content/datadog7/config.repo > datadog7.repo`

resulting in:

```plain
[datadog7]
name=datadog7
enabled=1
baseurl=http://pulp_content:24816/pulp/content/datadog7/
gpgcheck=0
repo_gpgcheck=0
```

where pulp_content is the container pulp-content

## DOCS

pipeline explaination
<https://docs.pulpproject.org/pulpcore/concepts.html#serving-content-with-pulp>
RPM specific docs
<https://docs.pulpproject.org/pulp_rpm/workflows/create_sync_publish.html>

## RPM upload

```plain
pulp rpm repository create --name geonet_external
pulp rpm content upload --relative-path nessus-agent --file /home/sysmaint/NessusAgent-10.4.0-es8.x86_64.rpm --chunk-size 100MB --repository geonet_external
pulp rpm publication create --repository geonet_external
pulp rpm distribution create --name geonet_external --base-path geonet_external --publication '/pulp/api/v3/publications/rpm/rpm/01892903-a295-76d8-843c-0da46c6023a2/'
```

```
[geonet_external]
name=geonet_external
enabled=1
baseurl=http://pulp_content:24816/pulp/content/geonet_external/
gpgcheck=0
repo_gpgcheck=0
```

## avrpm02 client installer guide

  dnf module enable python39
  dnf install python39-pip
  venv
  python3 -m venv
  python3 -m venv /root/pulp_env
  cd /root/pulp_env
  ls
  ls bin
  source bin/activate
  pip3 install pulp-cli[shell]
  pulp configure
  pulp config
  pulp config create
  pulp config edit

## password reset

 podman exec -it pulp-aio-pulp pulpcore-manager reset-admin-password
Please enter new password for user "admin":
Please enter new password for user "admin" again:
Successfully set password for "admin" user.

## update repo

create publication (version increment)

grab publication href

update the distribution (repo) to point to new version

pulp rpm distribution update --name geonet_external --publication '/pulp/api/v3/publications/rpm/rpm/01892347-0385-7807-ba1d-84f9b5c36d7e/'
