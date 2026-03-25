import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(summary: 'Any user op');

Response handler(Event event) => Response('user-any');
