import 'package:spry/spry.dart';
import '../../shared/index.dart' as shared;

final openapi = shared.userGetOpenApi;

Response handler(Event event) => Response('user-get');
