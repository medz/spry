import 'http/headers.dart';
import 'http/request.dart';
import 'http/url_search_params.dart';
import 'locals.dart';
import 'spry.dart';

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

  final Spry app;
  final Locals locals;
  final Request request;
  final Map<String, String> params;
  final String? address;
  final String id;

  Headers get headers => request.headers;
  String get method => request.method;
  Uri get url => request.url;

  String get pathname => url.path;
  String get path {
    if (url.hasQuery) {
      return '$pathname?${query.toQueryString()}';
    }

    return pathname;
  }

  URLSearchParams? _queryCache;
  URLSearchParams get query => _queryCache ??=
      url.hasQuery ? URLSearchParams() : URLSearchParams.parse(url.query);
}
