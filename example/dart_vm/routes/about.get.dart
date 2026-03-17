import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response(
    'Spry dart_vm example',
    ResponseInit(headers: {'content-type': 'text/plain; charset=utf-8'}),
  );
}
