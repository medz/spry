import 'package:spry/openapi.dart';

import 'schema_defs.dart' as schemas;

final userGetOpenApi = OpenAPI(
  summary: 'Get user',
  globalComponents: OpenAPIComponents(schemas: schemas.userSchemas),
);
