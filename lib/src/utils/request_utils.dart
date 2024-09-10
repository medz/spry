import '../_constants.dart';
import '../http/headers.dart';
import '../types.dart';

/// Reads current request event [Headers].
Headers useHeaders(Event event) => event.request.headers;

/// Gets current request event client address.
///
/// If result is not `null`, the value formated of `<ip>:<port>`.
String? getClientAddress(Event event) {
  return switch (event.locals[kClientAddress]) {
    String value => value,
    _ => null,
  };
}

/// Sets a client address in request [Event].
///
/// **NOTE**: This [setClientAddress] is provided to adapter developers
void setClientAddress(Event event, String address) {
  event.locals[kClientAddress] = address;
}

/// Returns the [Uri] for current request [Event].
Uri useRequestURI(Event event) => event.request.uri;

/// Returns the request [Event] matched route params.
Map<String, String> useParams(Event event) {
  return switch (event.locals[kParams]) {
    Map<String, String> params => params,
    _ => <String, String>{},
  };
}

/// Returns selected request matched route param.
String? useParam(Event event, String key) => useParams(event)[key];
