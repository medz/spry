import 'dart:io';
import 'dart:typed_data';

import '../_io_utils.dart';
import '../event.dart';
import '../http/response.dart';

Future<Response?> resove(Event _, Object? data) async {
  if (data is HttpClientResponse) {
    return Response(
      data.map(Uint8List.fromList),
      status: data.statusCode,
      headers: data.headers.toSpryHeaders(),
    );
  }

  return null;
}
