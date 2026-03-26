import 'package:spry/spry.dart';
import '../shared/index.dart' as shared;

final openapi = shared.homeOpenApi;

Response handler(Event event) => Response('home');
