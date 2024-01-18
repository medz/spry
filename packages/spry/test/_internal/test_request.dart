import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class TestRequest extends Stream<Uint8List> implements HttpRequest {
  @override
  X509Certificate? get certificate => throw UnimplementedError();

  @override
  HttpConnectionInfo? get connectionInfo => throw UnimplementedError();

  @override
  int get contentLength => throw UnimplementedError();

  @override
  List<Cookie> get cookies => throw UnimplementedError();

  @override
  HttpHeaders get headers => throw UnimplementedError();

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    throw UnimplementedError();
  }

  @override
  String get method => throw UnimplementedError();

  @override
  bool get persistentConnection => throw UnimplementedError();

  @override
  String get protocolVersion => throw UnimplementedError();

  @override
  Uri get requestedUri => throw UnimplementedError();

  @override
  HttpResponse get response => throw UnimplementedError();

  @override
  HttpSession get session => throw UnimplementedError();

  @override
  Uri get uri => throw UnimplementedError();
}
