// ignore_for_file: file_names

import 'package:spry/spry.dart';

Response handler(Event event) {
  final id = event.params.required('id');
  return Response.json({
    'id': id,
    'upper': id.toUpperCase(),
  });
}
