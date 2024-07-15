// ignore_for_file: file_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:spry/src/locals/locals.dart';

import '../../constants.dart';
import '../event/event.dart';
import '../handler/handler.dart';
import '../http/headers.dart';
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
  /// Creates a platform handler.
  PlatformHandler<T, R> createHandler(Spry app) {
    final handleWith = app.createHandleWith();

    return (T raw) async {
      final request = _RequestImpl();
      final locals = _RequestEventLocals(app);

      locals.set(kPlatform, this);
      locals.set(kRawRequest, raw);

      final event = _RequestEvent(locals: locals, request: request);

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

      locals.set(kEventParams, result?.params);
      if (result != null) {
        locals.set(kEventRoute, Route(id: result.route));
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
    for (final type in valuesOf('content-type')) {
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

class _RequestEvent implements Event {
  const _RequestEvent({
    required this.request,
    required this.locals,
  });

  @override
  final _RequestEventLocals locals;

  @override
  final Request request;
}

class _RequestEventLocals implements Locals {
  _RequestEventLocals(this.app);

  final Spry app;
  final Map locals = {};

  @override
  T get<T>(Object key) {
    return switch (locals[key]) {
      T value => value,
      _ => app.locals.get<T>(key),
    };
  }

  @override
  void remove(Object key) {
    locals.remove(key);
  }

  @override
  void set<T>(Object key, T value) {
    locals[key] = value;
  }
}
