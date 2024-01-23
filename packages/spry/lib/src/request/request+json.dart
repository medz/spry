// ignore_for_file: file_names

import 'dart:io';
import 'dart:convert' as convert;

import 'package:spry/src/_internal/map+value_of.dart';

import 'request+application.dart';
import 'request+locals.dart';
import 'request+text.dart';

extension Request$Json on HttpRequest {
  static const _key = #spry.request.cached.json;
  static const _lock = #spry.request.cached.json.lock;
  static const _codecKey = #spry.json.codec;

  /// Returns the request body as a JSON object.
  Future<T?> json<T>() async {
    final existing = locals[_key];
    if (locals[_lock] == true) return existing;

    // Try decode the request body as a JSON object.
    try {
      return locals[_key] = jsonCodec.decode(await text());
    } catch (_) {
      return locals[_key] = null;
    } finally {
      locals[_lock] = true;
    }
  }

  /// Returns JSON codec.
  convert.JsonCodec get jsonCodec {
    return locals.valueOf<convert.JsonCodec>(_codecKey, (_) {
      return application.locals.valueOf<convert.JsonCodec>(_codecKey, (_) {
        return convert.JsonCodec();
      });
    });
  }
}
