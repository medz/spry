import 'spry.dart';

/// Creates a plain handler.
Future<Response> Function(Request) toPlainHandler(Spry app) {
  final handler = toHandler(app);

  return (request) async => handler(createEvent(app, request));
}
