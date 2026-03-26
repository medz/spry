import 'package:spry/openapi.dart';

import 'schema_defs.dart' as schemas;

final userGetOpenApi = OpenAPI(
  summary: 'Get user',
  parameters: [
    OpenAPIRef.inline(OpenAPIParameter.path('id', schema: OpenAPISchema.string())),
  ],
  responses: {'200': OpenAPIRef.inline(OpenAPIResponse(description: 'OK'))},
  globalComponents: OpenAPIComponents(schemas: schemas.userSchemas),
);
