import '../http/request.dart';
import '../http/response.dart';
import 'handler.dart';

abstract interface class Application {
  Handler get handler;
  Future<Response> fetch(Request request, [Map? locals]);
  Handler resolve(String method, String path);
}
