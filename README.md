# refind

Web server for Redis data including Refile support.

<img src="https://raw.githubusercontent.com/evanx/refind/master/docs/readme/main.png"/>

## Use case

We want to publish data stored in Redis, including JSON objects that have been externalised to BLOB storage by
https://github.com/evanx/refile

```
```

## Config

See `lib/config.js`
```javascript
```

## Docker

You can build as follows:
```shell
docker build -t refind https://github.com/evanx/refind.git
```

See `bin/test.sh` https://github.com/evanx/refind/blob/master/bin/test.sh

Builds:
- isolated network `refind-network`
- isolated Redis instance named `refind-redis`
- this utility `evanx/refind`

We populate our test keys:
```
populate() {
}
```

We build a container image for this service:
```
docker build -t refind https://github.com/evanx/refind.git
```

We interactively run the service on our test Redis container:
```
docker run --name refind-instance --rm -i \
  --network=refind-network \
  -e host=$redisHost \
  -e pattern='*' \
  refind
```

## Implementation

See `lib/main.js`

```javascript
```

### Appication archetype

Incidently `lib/index.js` uses the `redis-koa-app-rpf` application archetype.
```
require('redis-koa-app-rpf')(require('./spec'), require('./main'));
```
where we extract the `config` from `process.env` according to the `spec` and invoke our `main` function.

See https://github.com/evanx/redis-koa-app-rpf.

This provides lifecycle boilerplate to reuse across similar applications.

<hr>
https://twitter.com/@evanxsummers
