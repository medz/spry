// ignore_for_file: file_names

import 'dart:convert';
import 'dart:typed_data';

import '../_constants.dart';
import '../event/event.dart';
import '../handler/handler.dart';
import '../http/headers/headers.dart';
import '../http/headers/headers+get.dart';
import '../http/request.dart';
import '../routing/route.dart';
import '../spry.dart';
import '../spry+fallback.dart';
import '../types.dart';
import '../routing/routes_builder+all.dart';
import '../utils/_spry_internal_utils.dart';
import 'platform.dart';
import 'platform_handler.dart';

extension PlatformAdapterCreateHandler<T, R> on Platform<T, R> {
  PlatformHandler<T, R> createHandler(Spry app) {
    final handleWith = app.createHandleWith();

    return (T raw) async {
      final request = _RequestImpl();
      final event = EventImpl(appLocals: app.locals, request: request);

      event.locals.set(Platform, this);
      event.locals.set(kRawRequest, raw);

      request.method = getRequestMethod(event, raw).toUpperCase().trim();
      request.uri = getRequestURI(event, raw);
      request.headers = getRequestHeaders(event, raw);
      request.body = getRequestBody(event, raw);

      final result =
          app.router.findDefinedRoute(request.method, request.uri.path);
      final handler = switch (result) {
        Result<Handler>(value: final handler) => handler,
        _ => app.getFallback(),
      };

      event.locals.set(Params, result?.params);
      if (result != null) {
        event.locals.set(Route, Route(id: result.route));
      }

      final response = await handleWith(handler, event);

      return respond(event, raw, response);
    };
  }
}

class _RequestImpl implements Request {
  @override
  late Stream<Uint8List>? body;

  @override
  Encoding get encoding => headers.contentTypeCharset;

  @override
  late final Headers headers;

  @override
  late final Uri uri;

  @override
  late final String method;
}

extension on Headers {
  Encoding get contentTypeCharset {
    for (final type in getAll('content-type')) {
      for (final param in type.split(';')) {
        final kv = param.trim().toLowerCase().split('=');
        if (kv.length == 2 && kv[0] == 'charset') {
          final encoding = Encoding.getByName(kv[1].trim());
          if (encoding != null) {
            return encoding;
          }
        }
      }
    }

    return utf8;
  }
}

extension<T> on Router<T> {
  Result<T>? findDefinedRoute(String method, String path) {
    return switch (method) {
      RoutesBuilderAll.kAllMethod =>
        lookup('${RoutesBuilderAll.kAllMethod}/$path'),
      'HEAD' => switch (lookup('HEAD/$path')) {
          Result<T> result => result,
          _ => findDefinedRoute('GET', path),
        },
      String method => switch (lookup('$method/$path')) {
          Result<T> result => result,
          _ => findDefinedRoute(RoutesBuilderAll.kAllMethod, path),
        },
    };
  }
}
