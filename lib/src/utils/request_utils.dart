import '../_constants.dart';
import '../http/headers.dart';
import '../http/request.dart';
import '../types.dart';
import 'create_error.dart';

/// Reads current [Request].
Request useRequest(Event event) {
  return switch (event.get<Request>(kRequest)) {
    Request request => request,
    _ => throw createError('Illegal Event'),
  };
}

/// Reads current request event [Headers].
Headers useHeaders(Event event) => useRequest(event).headers;

/// Gets current request event client address.
///
/// If result is not `null`, the value formated of `<ip>:<port>`.
String? getClientAddress(Event event) {
  return switch (event.get<String>(kClientAddress)) {
    String value => value,
    _ => null,
  };
}

/// Sets a client address in request [Event].
///
/// **NOTE**: This [setClientAddress] is provided to adapter developers
void setClientAddress(Event event, String address) {
  event.set(kClientAddress, address);
}

/// Returns the [Uri] for current request [Event].
Uri useRequestURI(Event event) => useRequest(event).uri;

/// Returns the request [Event] matched route params.
Map<String, String> useParams(Event event) {
  return switch (event.get(kParams)) {
    Map<String, String> params => params,
    _ => <String, String>{},
  };
}
