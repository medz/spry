import 'http/headers.dart';
import 'http/request.dart';
import 'http/url_search_params.dart';
import 'locals.dart';
import 'spry.dart';

/// Spry request event.
class Event {
  Event({
    required this.app,
    required this.request,
    required this.id,
    this.address,
    Locals? locals,
    Map<String, String>? params,
  })  : locals = locals ?? Locals(),
        params = params ?? {};

  /// Returns the spry application instane.
  final Spry app;

  /// Returns the request locals.
  final Locals locals;

  /// Returns the event request object.
  final Request request;

  /// Returns the request matched route params.
  final Map<String, String> params;

  /// Returns removed remote address.
  final String? address;

  /// The request event unique ID.
  final String id;

  /// Returns the request heanders.
  Headers get headers => request.headers;

  /// Returns the request method.
  String get method => request.method;

  /// Returns the request url.
  Uri get url => request.url;

  /// Returns the request url path without query.
  String get pathname => url.path;

  /// Returns the request url path with query.
  String get path {
    if (url.hasQuery) {
      return '$pathname?${query.toQueryString()}';
    }

    return pathname;
  }

  /// Returns the request query parmas.
  URLSearchParams get query => _queryCache ??=
      url.hasQuery ? URLSearchParams() : URLSearchParams.parse(url.query);
  URLSearchParams? _queryCache;
}
