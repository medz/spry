import 'locals.dart';
import 'params.dart';
import 'platform.dart';
import 'http/request.dart';
import 'route.dart';

abstract interface class RequestEvent {
  /// Additional data made available through the adapter.
  Platform? get platform;

  /// Contains custom data that was added to the request within the handle hook.
  Locals get locals;

  /// The [params] of the current route - e.g. for a route like `/blog/:slug`,
  ///  a `{ slug: string }` map.
  Params get params;

  /// Info about the current route.
  Route get route;

  /// The requested URL.
  Uri get url;

  /// The original request object
  Request get request;

  /// If you need to set headers for the response, you can do so using the this method.
  /// This is useful if you want the page to be cached, for example:
  ///
  /// ```dart
  /// function GET(RequestEvent event) {
  ///   event.setHeaders({
  ///     "age": "100",
  ///   });
  ///
  ///   return text('hello');
  /// }
  /// ```
  ///
  /// You cannot add a `set-cookie` header with `setHeaders` — use the `cookies` API instead.
  void setHeaders(Map<String, String> headers);

  /// The client's IP address, set by the adapter.
  String getClientAddress();
}
