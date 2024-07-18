import 'spry.dart';

Future<Response> Function(Request) toPlainHandler(Spry app) {
  final handler = toHandler(app);

  return (request) async => handler(createEvent(app, request));
}
