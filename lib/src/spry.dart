import 'dart:async';

import 'package:routingkit/routingkit.dart';

import '_utils.dart';
import 'http/request.dart';
import 'http/response.dart';
import 'event.dart';
import 'locals.dart';
import 'routing/routes_builder.dart';
import 'server/server.dart';
import 'server/serve.dart' as spry;
import 'types.dart';

/// Spry application.
class Spry extends RoutesBuilder {
  Spry._({
    this.dev = false,
    Locals? locals,
  })  : locals = locals ?? Locals({}),
        middleware = createRouter(),
        router = createRouter();

  /// The app is dev mode.
  final bool dev;

  /// The app global locals.
  final Locals locals;

  /// Middleware router context.
  @override
  final RouterContext<Middleware> middleware;

  /// Request handler route context.
  @override
  final RouterContext<Handler> router;

  /// Returns the app bind server.
  Server? get server => _server;
  Server? _server;

  /// Fetch a request handler.
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
      return Response(null, status: 404);
    }

    final event = Event(
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

  /// Creates a server from the app.
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
}

/// Creates a new [Spry] application.
const createSpry = Spry._;
