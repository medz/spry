import 'dart:io';

import '../context.dart';
import '../request.dart';
import '../response.dart';
import 'request_impl.dart';
import 'response_impl.dart';

class ContextImpl extends Context {
  /// Context data store.
  final Map<dynamic, dynamic> store = {};

  /// Creates a new [ContextImpl] instance.
  ContextImpl();

  /// Creates a new [ContextImpl] instance from [HttpRequest].
  factory ContextImpl.fromHttpRequest(HttpRequest httpRequest) {
    // Create a new context instance
    final ContextImpl context = ContextImpl();
    context
      // Store the Http request
      ..[HttpRequest] = httpRequest

      // Store the request and response
      ..[Request] = RequestImpl(request: httpRequest, context: context)
      ..[Response] =
          ResponseImpl(response: httpRequest.response, context: context);

    // Return the context
    return context;
  }

  @override
  Request get request => this[Request];

  @override
  Response get response => this[Response];

  @override
  @Deprecated('Use operator [] instead')
  Object? get(dynamic key) => store[key];

  @override
  @Deprecated('Use operator []= instead')
  void set(dynamic key, Object value) => store[key] = value;

  @override
  bool contains(dynamic key) => store.containsKey(key);

  @override
  operator [](dynamic key) => store[key];

  @override
  void operator []=(dynamic key, Object? value) => store[key] = value;
}
