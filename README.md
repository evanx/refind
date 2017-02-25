# refind

Web server for Redis data including Refile support.

<img src="https://raw.githubusercontent.com/evanx/refind/master/docs/readme/main.png"/>

## Use case

We want to publish data stored in Redis, including JSON objects that have been externalised to BLOB storage by https://github.com/evanx/refile

## Config

See `lib/config.js`
```javascript
module.exports = {
    description: 'Web server for Redis data including Refile support.',
    required: {
        redisHost: {
            description: 'the Redis host',
            default: 'localhost'
        },
        redisPort: {
            description: 'the Redis port',
            default: 6379
        },
        redisNamespace: {
            description: 'the Redis namespace',
            default: 'refind'
        },
        httpPort: {
            description: 'the HTTP port',
            default: 8871
        },
        httpLocation: {
            description: 'the HTTP location',
            default: 're'
        },
        blobStore: {
            description: 'the BLOB store options e.g. directory for file storage',
            default: 'data/'
        }
    }
}
```

## Docker

You can build as follows:
```shell
docker build -t refind https://github.com/evanx/refind.git
```

For a sample deployment script with the following `docker run` command, see https://github.com/evanx/refind/blob/master/bin/redeploy.sh
```
docker run --name refind -d \
  --restart unless-stopped \
  --network=host \
  -v $home/volumes/refind/data:/data:ro \
  -e NODE_ENV=$NODE_ENV \
  -e host=localhost \
  refind
```
where
- the host's Redis instance is used since `--network=host`
- host's filesystem is used relative to a specified `$home` directory for the read-only `refile` volume  

### Test

See `bin/test.sh` https://github.com/evanx/refind/blob/master/bin/test.sh

Builds:
- isolated network `refind-network`
- isolated Redis instance named `refind-redis`


## Implementation

See `lib/main.js`

```javascript
    api.get('/re/*', async ctx => {
        const path = ctx.params[0];
        const parts = path.split('/');
        const key = [...parts, 'j'].join(':')
        const [content] = await multiExecAsync(client, multi => {
            multi.get(key);
            multi.hincrby([config.redisNamespace, 'count:h'].join(':'), 'req', 1);
        });
        if (content) {
            ctx.set('Content-Type', 'application/json');
            ctx.body = content;
            return;
        }
        ...
```
If not found in Redis, then we try fetch via HTTP from `config.refileDomain`    
```javascript
        const sha = crypto.createHash('sha1').update(key).digest('hex');
        const refileUrl = [
            'https://' + config.refileDomain,
            'key',
            sha.substring(0, 3),
            parts.join('-') + '.json'
        ].join('/');
        const fetchRes = await fetch(refileUrl);
        if (fetchRes.status !== 200) {
            ctx.statusCode = fetchRes.status;
        } else {
            ctx.body = await fetchRes.json();
        }
```
where Refile path prefix includes the first three digits of the SHA of the key.

See https://github.com/evanx/refile


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
