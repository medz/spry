import '../request/request.dart';
import '../response/response.dart';

abstract interface class Responder {
  Future<Response> respond(Request request);
}
