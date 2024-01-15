// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:webfetch/webfetch.dart' show FormData, URLSearchParams;

import 'request+locals.dart';

export 'package:webfetch/webfetch.dart' show FormData;

extension Request$FormData on HttpRequest {
  static const _key = #spry.request.formdata;

  /// Returns the [FormData] from the request.
  Future<FormData> formData() async {
    final existing = locals[_key];
    if (existing is FormData) return existing;

    // If current is urlencoded
    if (headers.contentType?.mimeType.toLowerCase() ==
        'application/x-www-form-urlencoded') {
      return urlencodedFormData();
    }

    final parameters = headers.contentType?.parameters
        .map((key, value) => MapEntry(key.toLowerCase(), value));
    final boundary = parameters?['boundary'];
    if (boundary != null) {
      return locals[_key] = await FormData.decode(this, boundary);
    }

    /// Creates and returns an empty [FormData].
    return locals[_key] = FormData();
  }
}

extension on HttpRequest {
  Future<FormData> urlencodedFormData() async {
    final formData = FormData();
    final value = await utf8.decodeStream(this);
    final params = URLSearchParams(value);
    for (final (name, value) in params.entries()) {
      formData.append(name, value);
    }

    return locals[Request$FormData._key] = formData;
  }
}
