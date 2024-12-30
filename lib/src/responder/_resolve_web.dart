import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../event.dart';
import '../http/response.dart';
import '../server/runtime/js/_utils.dart';

Future<Response?> resove(Event _, Object? data) async {
  final response = data as web.Response;
  if (response.isA<web.Response>()) {
    return Response(
      response.body?.toDartStream(),
      status: response.status,
      headers: response.headers.toSpryHeaders(),
    );
  }

  return null;
}
