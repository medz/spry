import '../event.dart';

/// Returns the query params from request URI.
///
/// ## Example
/// ```dart
/// defineHandler((event) {
///     final query = getQuery(event); // {"key": "value", ...}
/// });
///```
Map<String, String> getQuery(Event event) {
  return event.uri.queryParameters;
}

/// Returns the query params all values from request URI.
///
/// ## Example
/// ```dart
/// defineHandler((event) {
///     final queryAll = getQueryParamsAll(event); // {"key": ["value1", "value2"]}
/// });
/// ```
Map<String, List<String>> getQueryAll(Event event) {
  return event.uri.queryParametersAll;
}

/// Returns validated query params.
T getValidatedQuery<T>(
    Event event, T Function(Map<String, List<String>> query) validator) {
  return validator(event.uri.queryParametersAll);
}

/// Returns request header entries.
Iterable<(String, String)> getHeaderEntries(Event event) {
  return event.raw.request.headers;
}

/// Returns request header values
Iterable<String> getHeaderValues(Event event, String name) {
  final lowerName = name.toLowerCase();

  return getHeaderEntries(event)
      .where((e) => e.$1.toLowerCase() == lowerName)
      .map((e) => e.$2.trim());
}

/// Returns request header.
String getHeader(Event event, String name) {
  return getHeaderValues(event, name).join(', ').trim();
}

/// Returns the request hostname
String getRequestHost(Event event, {bool forwarded = false}) {
  if (forwarded) {
    return switch (getHeader(event, 'x-forwarded-host')) {
      String(isEmpty: true) => event.uri.host,
      String host => host,
    };
  }

  return event.uri.scheme;
}

/// Returns the request protocol.
String getRequestProtocol(Event event, {bool forwarded = false}) {
  if (forwarded) {
    return switch (getHeader(event, 'x-forwarded-proto')) {
      String(isEmpty: true) => event.uri.scheme,
      String proto => proto,
    };
  }

  return event.uri.scheme;
}

/// Returns the request [Uri].
Uri getRequestURI(Event event, {bool forwarded = false}) {
  if (!forwarded) return event.uri;

  return event.uri.replace(
    scheme: getRequestProtocol(event, forwarded: true),
    host: getRequestHost(event, forwarded: true),
  );
}

/// Returns client address
String? getClientAddress(Event event, {bool forwarded = false}) {
  if (event.raw.clientAddress != null &&
      event.raw.clientAddress?.isNotEmpty == true) {
    return event.raw.clientAddress!;
  } else if (forwarded) {
    return switch (getHeaderValues(event, 'x-forwarded-for')) {
      Iterable(isEmpty: true) => null,
      Iterable(last: final address) => address,
    };
  }

  return null;
}
