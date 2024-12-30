import '../../http/request.dart';
import '../../http/response.dart';
import '../server.dart';

final class RuntimeServer extends Server {
  RuntimeServer(super.options);

  @override
  String? get hostname => throw UnimplementedError();

  @override
  int? get port => throw UnimplementedError();

  @override
  get runtime => throw UnimplementedError();

  @override
  Future<void> close({bool force = false}) {
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

  @override
  String? remoteAddress(request) {
    throw UnimplementedError();
  }
}
