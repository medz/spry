part of '../request_event.dart';

extension on HttpRequest {
  Request returnsOrCreate(ProvideInject store) {
    if (store.contains(this)) {
      return store.inject(this);
    }

    final request = _createNewRequest(store);
    store.provide(this, () => request);

    return request;
  }

  Request _createNewRequest(ProvideInject store) {
    final headers = this.headers.returnsOrCreate(store);

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
