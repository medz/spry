import '../request/request.dart';
import '../response/response.dart';
import 'responder.dart';

class ClosureResponder implements Responder {
  final Future<Response> Function(Request request) _closure;

  const ClosureResponder(Future<Response> Function(Request request) closure)
      : _closure = closure;

  @override
  Future<Response> respond(Request request) => _closure(request);
}
