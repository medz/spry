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
    final ContextImpl context = ContextImpl()..[HttpRequest] = httpRequest;

    // Create a spry request instance
    final RequestImpl spryRequest = RequestImpl(httpRequest);

    // Create a spry response instance
    final ResponseImpl spryResponse = ResponseImpl(httpRequest.response);

    // Store context
    context
      ..[Request] = spryRequest
      ..[Response] = spryResponse
      ..[Context] = context;

    spryRequest.context = context;
    spryResponse.context = context;

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
