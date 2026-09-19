// Leitet www.<domain> dauerhaft auf die Wurzeldomain um, damit die Seite unter
// genau einer Adresse erreichbar ist. Läuft als CloudFront Function am
// Viewer-Request, also vor dem Cache.
function handler(event) {
    var request = event.request;
    var host = request.headers.host ? request.headers.host.value : '';

    if (host !== '${www_domain}') {
        return request;
    }

    var target = 'https://${apex_domain}' + request.uri;

    // Mehrfach belegte Parameter werden nicht berücksichtigt, die Seite kennt
    // keine. Kampagnenparameter wie utm_source bleiben erhalten.
    var query = [];
    for (var key in request.querystring) {
        query.push(key + '=' + request.querystring[key].value);
    }
    if (query.length > 0) {
        target = target + '?' + query.join('&');
    }

    return {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: {
            location: { value: target }
        }
    };
}
