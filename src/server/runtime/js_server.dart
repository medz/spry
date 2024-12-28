import '../../http/request.dart';
import '../../http/response.dart';
import '../server.dart';
import 'js/bun_server.dart' as bun;

class RuntimeServer extends Server {
  RuntimeServer(super.options) : server = bun.RuntimeServer(options);

  final Server server;

  @override
  Future<void> ready() => server.ready();

  @override
  Future<void> close() => server.close();

  @override
  Future<Response> fetch(Request request) => server.fetch(request);

  @override
  get runtime => server.runtime;
}
