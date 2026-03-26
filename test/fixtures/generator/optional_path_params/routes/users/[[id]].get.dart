import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(summary: 'Get user by optional id');

Response handler(Event event) => Response('user-get');
