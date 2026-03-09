// ignore_for_file: file_names

import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) async {
  final startedAt = DateTime.now();
  final response = await next();
  final duration = DateTime.now().difference(startedAt).inMilliseconds;
  print('${event.request.method} ${event.request.url.path} -> ${response.status} (${duration}ms)');
  return response;
}
