# MediaWiki Compose

**Work in progress: More documentations, examples, and QoL improvements to come. Understand the configuration involved before attempting to deploy this to production envrionment**

This is an easy to use [Mediawiki](https://www.mediawiki.org/wiki/MediaWiki) Docker Compose deployment setup with modern web features and sensible defaults. Specifically:
1. Out of the box [QUIC/HTTP3](https://www.cloudflare.com/learning/performance/what-is-http3/) support
2. Out of the box [Brotli](https://github.com/google/brotli) compression
3. S3 (or S3 compatible services) for static resources storage
4. Visual Editor and Parsoid support
5. Varnish for static caching
6. Redis for object caching

# Get Started
1. Build the container images with:
```
./scripts/build.sh
```

1. To start the server, you first need an existing MediaWiki installation, copy `LocalSettings.php` to `conf/mediawiki`. Initial setup is not available due to the deployment is pre-configured for Short URL.
2. The example nginx config included in this repo assumes the hostname to be localhost and [Short URL mode](https://www.mediawiki.org/wiki/Manual:Short_URL), configure as appropriate to your needs. In most cases, you only need to update the hostname definitions and certificate paths in `conf/nginx-fastcgi` and `conf/nginx-ingress`
3. The `docker-compose.yaml` file includes a MariaDB container config, you can use it if you are not using an external DB. Otherwise, config the password in `docker-compose.yaml` and import the database data into the container. The data will presist after contianer shutdown.
4. `docker compose up -d`

## Hack it!
Every MediaWiki deployment has its requirements, if the default patterns and configs aren't the best for your circumstances, you can modify it to your needs.

# Architecture and Best Practices
The compose deployment consists of the following containers:
- `mwc_ingress`: Exposes 80, 443/tcp, 443/udp (for HTTP3). This Nginx container is responsible for TLS termination, static file routing, and Brotli/Gzip compression
- `mwc_accelerator`: Varnish container. If the user is not logged in, it will cache the generated HTML from MediaWiki PHP and serve that cache to users. It can auto-detect user device and serve the correct version of the page (desktop/mobile).
- `mwc_fastcgi`: Another Nginx container. This one is responsible for MediaWiki routing and FastCGI handling.
- `mwc_app`: PHP-FPM container. It contains the actual MediaWiki installation.
- `mwc_objcache`: Redis container. Reponsible for object caching (such as session, search queries, and localization)
- `mwc_database`: MariaDB container.

## Stateless Deployment
It is best pratice to not include any states (in the context of MW, database data, images directory, etc) in the deployment. The reasons are:
1. It is a lot more portable, we only need to deploy the code (included in the docker image) and configuration.
2. Much easier to implement auto-scaling and load balancing, as we don't need to sync stats across different instances.
3. More than offen, having all data served by VPS bandwidth is not cost-effective or efficient performance-wise.

To acheive this, we need to decouple database data, image directory, and cache data. Image directory can be decoupled by using the [AWS](https://www.mediawiki.org/wiki/Extension:AWS) extension, which the docker image includes. Database and cache data can be decoupled by ulitising managed solutions such as Amazon RDS.
