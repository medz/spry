import 'package:spry/openapi.dart';

final openapi = OpenAPI(
  summary: 'Get user',
  globalComponents: OpenAPIComponents(
    schemas: {
      'User': {'type': 'object'},
    },
  ),
);

// fixture
