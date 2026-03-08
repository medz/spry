import 'package:ht/ht.dart' show Headers, Request, URLSearchParams;
import 'package:osrv/osrv.dart' show RequestContext;

import 'app_context.dart';
import 'locals.dart';
import 'route_params.dart';

final class Event {
  Event({
    required this.app,
    required this.request,
    required this.context,
    RouteParams? params,
    Locals? locals,
  }) : params = params ?? RouteParams(<String, String>{}),
       locals = locals ?? Locals(<Symbol, Object?>{});

  final AppContext app;
  final Request request;
  final RequestContext context;
  final RouteParams params;
  final Locals locals;

  Headers get headers => request.headers;
  String get method => request.method;
  Uri get url => request.url;
  String get pathname => url.path;

  String get path {
    if (url.hasQuery) {
      return '$pathname?${query.toString()}';
    }

    return pathname;
  }

  URLSearchParams get query => URLSearchParams(url.query);
}
