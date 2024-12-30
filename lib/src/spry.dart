import 'dart:async';

import 'package:routingkit/routingkit.dart';

import '_utils.dart';
import 'http/request.dart';
import 'http/response.dart';
import 'event.dart';
import 'locals.dart';
import 'server/server.dart';
import 'server/serve.dart' as spry;

typedef Next = Future<Response> Function();
typedef Middleware = FutureOr<Response> Function(Event event, Next next);

typedef Handler<T> = FutureOr<T>? Function(Event event);

class Spry {
  Spry._({
    this.dev = false,
    Locals? locals,
  })  : locals = locals ?? Locals({}),
        middleware = createRouter(),
        router = createRouter();

  final bool dev;
  final Locals locals;
  final RouterContext<Middleware> middleware;
  final RouterContext<Handler> router;

  Server? get server => _server;
  Server? _server;

  Future<Response> fetch(Request request) async {
    final route = switch (request.method) {
      'HEAD' => switch (findRoute(router, 'HEAD', request.url.path)) {
          MatchedRoute<Handler> route => route,
          _ => findRoute(router, 'GET', request.url.path),
        },
      String method => switch (findRoute(router, method, request.url.path)) {
          MatchedRoute<Handler> route => route,
          _ => findRoute(router, null, request.url.path),
        },
    };
    if (route == null) {
      return Response(null, status: 204);
    }

    final event = Event(
      id: createUniqueID(),
      app: this,
      request: request,
      address: server?.remoteAddress(request.runtime),
    );
    Next respond = () async {
      if (route.params?.isNotEmpty == true) {
        event.params.clear();
        event.params.addAll(route.params!);
      }
      return await responder(event, route.data(event));
    };
    for (final match
        in findAllRoutes(middleware, request.method, request.url.path)) {
      final prev = respond;
      respond = () async {
        if (match.params?.isNotEmpty == true) {
          event.params.clear();
          event.params.addAll(match.params!);
        }
        return await match.data(event, prev);
      };
    }

    return await respond();
  }

  Server serve({String? hostname, int? port, bool? reusePort}) {
    if (_server != null) {
      throw StateError('Server is already running.');
    }

    return _server = spry.serve(
      hostname: hostname,
      port: port,
      reusePort: reusePort,
      fetch: (request, _) => fetch(request),
    );
  }

  void use(Middleware fn, {String? method, String path = '/'}) {
    addRoute(middleware, method, path, fn);
  }

  void on<T>(Handler<T> handler, {String? method, String path = '/'}) {
    addRoute(router, method, path, handler);
  }

  void all<T>(String path, Handler<T> handler) => on(path: path, handler);
  void get<T>(String path, Handler<T> handler) =>
      on(method: 'GET', path: path, handler);
  void head<T>(String path, Handler<T> handler) =>
      on(method: 'HEAD', path: path, handler);
  void post<T>(String path, Handler<T> handler) =>
      on(method: 'POST', path: path, handler);
  void patch<T>(String path, Handler<T> handler) =>
      on(method: 'PATCH', path: path, handler);
  void put<T>(String path, Handler<T> handler) =>
      on(method: 'PUT', path: path, handler);
  void delete<T>(String path, Handler<T> handler) =>
      on(method: 'DELETE', path: path, handler);
}

const createSpry = Spry._;
