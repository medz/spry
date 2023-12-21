import 'dart:async';

import '../request/request.dart';
import '../response/response.dart';
import 'responder.dart';

class ClosureResponder implements Responder {
  final FutureOr<Response> Function(Request request) _closure;

  const ClosureResponder(FutureOr<Response> Function(Request request) closure)
      : _closure = closure;

  @override
  FutureOr<Response> respond(Request request) => _closure(request);
}
