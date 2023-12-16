part of '../request_event.dart';

const _key = ContainerKey<Request>(#spry._internal.request);

extension on HttpRequest {
  /// The Web API compatible request object.
  Request returnsOrCreate(Container container) {
    final existing = container.get(_key);
    if (existing != null) return existing;

    final request = _createNewRequest(container);
    container.set(_key, value: request);

    return request;
  }

  Request _createNewRequest(Container container) {
    final headers = this.headers.returnsOrCreate(container);

    return Request(
      requestedUri,
      body: this,
      method: method.toLowerCase(),
      headers: headers,
      cache: headers.cache,
      credentials: headers.credentials,
      destination: headers.destination,
      integrity: headers.get('integrity'),
      mode: headers.mode,
      redirect: headers.redirect,
      referrer: headers.get('referer'),
      referrerPolicy: headers.referrerPolicy,
    );
  }
}

extension on Headers {
  RequestCache get cache {
    final cacheControl =
        get('cache-control')?.toLowerCase().split(',').map((e) => e.trim());
    for (final cache in RequestCache.values) {
      if (cacheControl?.contains(cache.value) == true) {
        return cache;
      }
    }

    return RequestCache.default_;
  }

  RequestCredentials get credentials {
    final site = get('sec-fetch-site')?.toLowerCase();
    for (final cred in RequestCredentials.values) {
      if (cred.value == site) {
        return cred;
      }
    }

    return RequestCredentials.omit;
  }

  RequestDestination? get destination {
    final destination = get('sec-fetch-dest')?.toLowerCase();
    for (final dest in RequestDestination.values) {
      if (dest.value == destination) {
        return dest;
      }
    }

    return null;
  }

  RequestMode? get mode {
    final mode = get('sec-fetch-mode')?.toLowerCase();
    for (final m in RequestMode.values) {
      if (m.value == mode) {
        return m;
      }
    }

    return null;
  }

  RequestRedirect? get redirect {
    // TODO: This is redrect mode ?
    final redirect = get('sec-fetch-redirect')?.toLowerCase();
    for (final r in RequestRedirect.values) {
      if (r.name == redirect) {
        return r;
      }
    }

    return null;
  }

  ReferrerPolicy? get referrerPolicy {
    final referrerPolicy = get('referrer-policy')?.toLowerCase();
    for (final r in ReferrerPolicy.values) {
      if (r.value == referrerPolicy) {
        return r;
      }
    }

    return null;
  }
}
