// ignore_for_file: file_names

import 'dart:io';

import 'package:routingkit/routingkit.dart';

import '_internal/application+factory.dart';
import '_internal/map+value_of.dart';
import '_internal/request.dart';
import 'application.dart';
import 'exception/abort.dart';
import 'exception/application+exceptions.dart';
import 'exception/exception_source.dart';
import 'handler/handler.dart';
import 'request/request+params.dart';
import 'response/responsible.dart';
import 'routing/route.dart';

extension Application$Handler on Application {
  Handler get handler => _handler;
}

extension on Application {
  _ApplicationHandler get _handler {
    if (locals[#spry.server.initialized] != true && factory == null) {
      final error = StateError(
          'HTTP Server not initialized, You must call `app.run()` bootstrap your Spry application.');
      logger.severe(error.message, error);

      throw error;
    }

    return locals.valueOf(
      #spry.handler,
      (_) => _ApplicationHandler(this)..initialize(),
    );
  }
}

class _ApplicationHandler implements Handler<Object?> {
  final Application application;
  late final Router<(Route, Handler)> router;

  _ApplicationHandler(this.application) {
    application.locals[#spry.handler] = this;
    router = TrieRouter(
      caseSensitive: application.routes.caseSensitive,
      logger: application.logger,
    );

    application.logger.config('Routes created');
  }

  /// Initializes the router handler.
  void initialize() {
    for (final route in application.routes) {
      final segments = route.segments.where((element) {
        if (element is ConstSegment) {
          return element.value.isNotEmpty;
        }

        return true;
      });

      router.register(
        (route, route.handler),
        [ConstSegment(route.method.toUpperCase()), ...segments],
      );
    }

    application.logger.config('Routes initialized');
  }

  /// Handler for incoming requests.
  @override
  Future<Object?> handle(HttpRequest incoming) async {
    if (application.factory != null) {
      application.server = await application.factory!(application);
      application.locals[#spry.server.initialized] = true;
    }

    final request =
        SpryRequest.from(application: application, request: incoming);
    final response = request.response;

    try {
      final (route, handler) = lookup(request);
      request.locals[#spry.request.route] = route;

      // Runs the handler and gets the result.
      final result = await handler.handle(request);

      // If result is exception or error, throws it.
      if (result is Exception || result is Error) {
        throw result!;
      }

      // Result is null or response is closed, returns it.
      if (!response.isClosed) {
        await Responsible.create(result).respond(request);
      }

      return result;
    } catch (error, stackTrace) {
      final source = ExceptionSource(
        exception: error,
        stackTrace: stackTrace,
        responseClosedFactory: () => response.isClosed,
      );

      await application.exceptions.process(source, request);
    } finally {
      // Safely closes the response.
      await response.safeClose();
    }

    return null;
  }

  /// Lookup the handler for the given request.
  (Route, Handler) lookup(SpryRequest request) {
    final method = request.method.toUpperCase();
    final segments = request.uri.pathSegments;

    // If the request is `HEAD`, finds the `HEAD` handler, if not found,
    // try to find the `GET` handler.
    if (method == 'HEAD') {
      final head = router.lookup(
        ['HEAD', ...segments],
        request.params,
      );
      if (head != null) return head;

      final get = router.lookup(
        ['GET', ...segments],
        request.params,
      );
      if (get != null) return get;
    }

    final result = router.lookup(
      [method, ...segments],
      request.params,
    );

    if (result == null) {
      final error = Abort(HttpStatus.notFound);
      application.logger.warning(
        'No handler found for ${request.method} ${request.uri}',
        error,
      );

      throw error;
    }

    return result;
  }
}
