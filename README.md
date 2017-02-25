# resend

Web server for Redis data including Refile support.

<img src="https://raw.githubusercontent.com/evanx/resend/master/docs/readme/main.png"/>

## Use case

```
```

## Config

See `lib/config.js`
```javascript
```

## Docker

You can build as follows:
```shell
docker build -t resend https://github.com/evanx/resend.git
```

See `bin/test.sh` https://github.com/evanx/resend/blob/master/bin/test.sh

Builds:
- isolated network `resend-network`
- isolated Redis instance named `resend-redis`
- this utility `evanx/resend`

We populate our test keys:
```
populate() {
}
```

We build a container image for this service:
```
docker build -t resend https://github.com/evanx/resend.git
```

We interactively run the service on our test Redis container:
```
docker run --name resend-instance --rm -i \
  --network=resend-network \
  -e host=$redisHost \
  -e pattern='*' \
  resend
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
