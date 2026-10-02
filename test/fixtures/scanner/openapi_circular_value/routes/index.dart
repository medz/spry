import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';
import '../shared.dart' as shared;

final openapi = OpenAPI(summary: shared.first);

Response handler(Event event) => Response('home');
