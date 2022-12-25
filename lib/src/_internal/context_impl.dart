import 'dart:io';

import '../context.dart';
import '../request.dart';
import '../response.dart';
import 'request_impl.dart';
import 'response_impl.dart';

class ContextImpl implements Context {
  @override
  final Request request;

  @override
  final Response response;

  /// Creates a new [ContextImpl] instance.
  const ContextImpl(this.request, this.response);

  /// Creates a new [ContextImpl] instance from [HttpRequest].
  factory ContextImpl.fromHttpRequest(HttpRequest request) {
    return ContextImpl(
      RequestImpl(request),
      ResponseImpl(request.response),
    );
  }
}
