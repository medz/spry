import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(summary: 'No responses here');

Response handler(Event event) => Response('ok');
