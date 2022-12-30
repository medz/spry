import 'dart:io';

import '../context.dart';
import '../request.dart';
import '../response.dart';
import '../../constants.dart';
import 'request_impl.dart';
import 'response_impl.dart';

class ContextImpl extends Context {
  /// Context data store.
  final Map<Object, Object> store = {};

  /// Creates a new [ContextImpl] instance.
  ContextImpl();

  /// Creates a new [ContextImpl] instance from [HttpRequest].
  factory ContextImpl.fromHttpRequest(HttpRequest request) {
    // Create a new context instance
    final ContextImpl context = ContextImpl();

    // Create a spry request instance
    final RequestImpl spryRequest = RequestImpl(request);

    // Create a spry response instance
    final ResponseImpl spryResponse = ResponseImpl(request.response);

    // Store context
    context.set(SPRY_HTTP_ORIGIN_REQUEST, request);
    context.set(SPRY_HTTP_REQUEST, spryRequest);
    context.set(SPRY_HTTP_RESPONSE, spryResponse);

    spryRequest.context = context;
    spryResponse.context = context;

    // Return the context
    return context;
  }

  @override
  Request get request => get(SPRY_HTTP_REQUEST) as Request;

  @override
  Response get response => get(SPRY_HTTP_RESPONSE) as Response;

  @override
  Object? get(Object key) => store[key];

  @override
  void set(Object key, Object value) => store[key] = value;

  @override
  bool contains(Object key) => store.containsKey(key);
}
