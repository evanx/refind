const assert = require('assert');
const crypto = require('crypto');
const h = require('render-html-rpf');
const lodash = require('lodash');
const multiExecAsync = require('multi-exec-async');
const mapProperties = require('map-properties');

module.exports = async appx => {
    const {config, logger, client, api} = appx;
    logger.info({config}, process.env.NODE_ENV);
    api.get('/re/analytics', async ctx => {
        const [countsRes] = await multiExecAsync(client, multi => {
            multi.hgetall([config.redisNamespace, 'count:h'].join(':'));
        });
        const counts = mapProperties(countsRes || {}, value => parseInt(value));
        const analytics = {counts};
        if (/(Mobile)/.test(ctx.get('user-agent'))) {
            ctx.body = h.page({
                title: 'refind',
                heading: 'Analytics',
                content: [{
                    name: 'pre',
                    content: JSON.stringify(analytics, null, 2)}
                ],
                footerLink: 'https://github.com/evanx/refind'
            });
        } else {
            ctx.body = analytics;
        }
    });
    api.get('/re/*', async ctx => {
        const path = ctx.params[0];
        await multiExecAsync(client, multi => {
            multi.hincrby([config.redisNamespace, 'count:h'].join(':'), 'req', 1);
        });
        const parts = path.split('/');
        const key = [...parts, 'json'].join(':')
        const sha = crypto.createHash('sha1').update(key).digest('hex');
        const [content] = await multiExecAsync(client, multi => {
            multi.get(key);
        });
        if (content) {
            ctx.set('Content-Type', 'application/json');
            ctx.body = content;
            return;
        }
        //throw new Error('test');
        ctx.redirect = `/key/${sha.substring(0, 3)}/${parts.join('-')}.json`;
        logger.debug({key, sha}, ctx.redirect);
    });
}
