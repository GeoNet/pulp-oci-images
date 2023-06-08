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

`pulp rpm publication create --repository datadog_7`

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
