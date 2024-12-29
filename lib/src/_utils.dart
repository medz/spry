import 'dart:typed_data';

import 'package:slugid/slugid.dart';

import 'http/formdata.dart';
import 'http/response.dart';

String createUniqueID() => Slugid.nice().toString();

// TODO
Response resolveResponse(Object? data) {
  return switch (data) {
    Response response => response,
    Stream<Uint8List> stream => Response(stream),
    Uint8List bytes => Response.fromBytes(bytes),
    String value => Response.fromString(value),
    FormData form => Response.fromFormData(form),
    _ => Response(null, status: 404),
  };
}
