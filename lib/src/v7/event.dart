import '../http/headers.dart';
import '../http/request.dart';
import '../http/url_search_params.dart';
import '../locals.dart';
import 'app_context.dart';

final class Event {
  Event({
    required this.app,
    required this.request,
    this.address,
    Map<String, String>? params,
    Locals? locals,
  }) : params = params ?? <String, String>{},
       locals = locals ?? Locals();

  final AppContext app;
  final Request request;
  final String? address;
  final Map<String, String> params;
  final Locals locals;

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

  URLSearchParams get query =>
      _queryCache ??=
          url.hasQuery ? URLSearchParams.parse(url.query) : URLSearchParams();
  URLSearchParams? _queryCache;
}
