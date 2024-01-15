// ignore_for_file: file_names

import 'dart:io';

import 'package:webfetch/webfetch.dart' show URLSearchParams;

import '../_internal/map+value_of.dart';
import 'request+locals.dart';

export 'package:webfetch/webfetch.dart' show URLSearchParams;

extension Request$SearchParams on HttpRequest {
  static const _key = #spry.request.searchParams;

  /// Returns the [URLSearchParams] from the request.
  URLSearchParams get searchParams {
    return locals.valueOf(_key, (_) {
      return locals[_key] = URLSearchParams(uri.queryParametersAll);
    });
  }
}
