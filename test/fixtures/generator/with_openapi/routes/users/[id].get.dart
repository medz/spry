import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(summary: 'Get user');

Response handler(Event event) => Response('user-get');
