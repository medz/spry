import '../../http/request.dart';
import '../../http/response.dart';
import '../server.dart';

final class RuntimeServer extends Server {
  RuntimeServer(super.options);

  @override
  get runtime => throw UnimplementedError();

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> ready() {
    throw UnimplementedError();
  }

  @override
  Future<Response> fetch(Request request) {
    throw UnimplementedError();
  }
}
