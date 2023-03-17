import 'package:spry/spry.dart';

import '_internal/constants.dart';

/// [Request] params extension.
///
/// ```dart
/// handler(Context context) {
///  final String name = context.request.params['name'];
/// }
/// ```
extension RequestParamsExtension on Request {
  /// Get the request params.
  Map<String, Object?> get params {
    dynamic params = context[SPRY_REQUEST_PARAMS];
    if (params is Map) return params.cast<String, Object?>();

    context[SPRY_REQUEST_PARAMS] = params = <String, Object?>{};

    return context[SPRY_REQUEST_PARAMS];
  }

  /// Get a request param.
  Object? param(String name) => params[name];
}
