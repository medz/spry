// ignore_for_file: file_names

import 'dart:io';

import 'package:routingkit/routingkit.dart';

import '../_internal/map+value_of.dart';
import 'request+locals.dart';

extension Request$Params on HttpRequest {
  /// Returns current request parameters.
  Params get params {
    return locals.valueOf(#spry.request.params, (_) {
      return locals[#spry.request.params] = Params();
    });
  }
}
