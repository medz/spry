import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Any-method user operation',
  globalComponents: OpenAPIComponents(
    schemas: {
      'UserId': OpenAPISchema.string(),
    },
  ),
);

Response handler(Event event) => Response('any');
