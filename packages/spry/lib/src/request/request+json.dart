// ignore_for_file: file_names

import 'dart:io';
import 'dart:convert';

import 'request+locals.dart';
import 'request+text.dart';

extension Request$Json on HttpRequest {
  static const _key = #spry.request.cached.json;
  static const _lock = #spry.request.cached.json.lock;

  /// Returns the request body as a JSON object.
  Future<Object?> json() async {
    final existing = locals[_key];
    if (locals[_lock] == true) return existing;

    // Try decode the request body as a JSON object.
    try {
      return locals[_key] = jsonDecode(await text());
    } catch (_) {
      return locals[_key] = null;
    } finally {
      locals[_lock] = false;
    }
  }
}
