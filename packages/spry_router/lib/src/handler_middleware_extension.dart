import 'dart:async';

import 'package:spry/spry.dart';

import '_internal/constants.dart';
import 'param_middleware.dart';
import 'request_params_extension.dart';

/// Handler Middleware extension.
extension HandlerMiddlewareExtension on Handler {
  /// Use a middleware.
  Handler use(Middleware middleware) {
    return (Context context) => middleware(context, () => this(context));
  }

  /// Use a param middleware.
  Handler param(String name, ParamMiddleware middleware) {
    return (Context context) async {
      final Map<String, dynamic> params = context.request.params;
      if (params.containsKey(name)) {
        FutureOr<void> next(dynamic value) {
          _writeParam(context, name, value);

          return this(context);
        }

        final dynamic value = params[name];
        return middleware(context, value, next);
      }

      return this(context);
    };
  }

  /// Write a param value to the context.
  static void _writeParam(Context context, String name, dynamic value) {
    final Map<String, dynamic> params = context.request.params;
    params[name] = value;

    context.set(SPRY_REQUEST_PARAMS, params);
  }
}
