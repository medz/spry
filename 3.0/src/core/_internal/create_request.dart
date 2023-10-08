import 'dart:io';

import '../../standard_web_polyfills.dart';
import 'create_headers.dart';

Request createRequst(HttpRequest request) {
  return Request(
    request.requestedUri,
    body: request,
    method: request.method.toUpperCase(),
    headers: createHeaders(request.headers),
    cache: _resolveCacheControl(request.headers),
    credentials: _resolveCredentials(request.headers),
    destination: _resolveDestination(request.headers),
    integrity: request.headers.value(HttpHeaders.contentMD5Header),
    mode: _resolveMode(request.headers),
    referrer: request.headers.value(HttpHeaders.refererHeader),
    referrerPolicy: _resolveReferrerPolicy(request.headers),
  );
}

/// Returns the referrer policy.
ReferrerPolicy _resolveReferrerPolicy(HttpHeaders headers) {
  final referrerPolicy = headers.value(HttpHeaders.refererHeader);

  return switch (referrerPolicy) {
    'no-referrer' => ReferrerPolicy.noReferrer,
    'no-referrer-when-downgrade' => ReferrerPolicy.noReferrerWhenDowngrade,
    'origin' => ReferrerPolicy.origin,
    'origin-when-cross-origin' => ReferrerPolicy.originWhenCrossOrigin,
    'same-origin' => ReferrerPolicy.sameOrigin,
    'strict-origin' => ReferrerPolicy.strictOrigin,
    'strict-origin-when-cross-origin' =>
      ReferrerPolicy.strictOriginWhenCrossOrigin,
    'unsafe-url' => ReferrerPolicy.unsafeUrl,
    _ => ReferrerPolicy.default_,
  };
}

/// Returns the mode.
RequestMode _resolveMode(HttpHeaders headers) {
  final mode = headers.value('sec-fetch-mode');
  for (final m in RequestMode.values) {
    if (m.value == mode?.toLowerCase()) {
      return m;
    }
  }

  return RequestMode.cors;
}

/// Returns the destination.
RequestDestination _resolveDestination(HttpHeaders headers) {
  final destination = headers.value('sec-fetch-dest');
  for (final dest in RequestDestination.values) {
    if (dest.value == destination?.toLowerCase()) {
      return dest;
    }
  }

  return RequestDestination.default_;
}

/// Returns the credentials from the given headers.
RequestCredentials _resolveCredentials(HttpHeaders headers) {
  final credentials = headers.value(HttpHeaders.authorizationHeader);
  if (credentials == null) {
    return RequestCredentials.omit;
  }

  if (credentials.toLowerCase().startsWith('basic')) {
    return RequestCredentials.include;
  }

  return RequestCredentials.omit;
}

/// Returns the cache control directive from the given headers.
RequestCache _resolveCacheControl(HttpHeaders headers) {
  final cacheControl = headers.value(HttpHeaders.cacheControlHeader);
  if (cacheControl == null) {
    return RequestCache.default_;
  }

  final directives = cacheControl.split(',').map((s) => s.trim());
  if (directives.contains('no-cache')) {
    return RequestCache.noCache;
  }

  if (directives.contains('no-store')) {
    return RequestCache.noStore;
  }

  if (directives.contains('only-if-cached')) {
    return RequestCache.onlyIfCached;
  }

  return RequestCache.default_;
}
