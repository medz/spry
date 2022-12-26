import 'dart:io';

import '../context.dart';
import '../request.dart';
import '../response.dart';
import '../../constants.dart';
import 'request_impl.dart';
import 'response_impl.dart';

class ContextImpl implements Context {
  @override
  final Request request;

  @override
  final Response response;

  /// Context data store.
  final Map<Object, Object> store = {};

  /// Creates a new [ContextImpl] instance.
  ContextImpl(this.request, this.response);

  /// Creates a new [ContextImpl] instance from [HttpRequest].
  factory ContextImpl.fromHttpRequest(HttpRequest request) {
    // Create a new context instance
    final ContextImpl context = ContextImpl(
      RequestImpl(request),
      ResponseImpl(request.response),
    );

    // Store the context in the request
    context.set(SPRY_HTTP_REQUEST, request);

    // Return the context
    return context;
  }

  @override
  Object? get(Object key) => store[key];

  @override
  void set(Object key, Object value) => store[key] = value;
}
