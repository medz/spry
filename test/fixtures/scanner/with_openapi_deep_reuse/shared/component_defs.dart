import 'package:spry/openapi.dart';

import 'schema_leaf.dart' as schemas;

final bearerScheme = OpenAPISecurityScheme.http(
  scheme: 'bearer',
  bearerFormat: 'JWT',
);

final components = OpenAPIComponents(
  schemas: {'UserId': schemas.userIdSchema, 'User': schemas.userSchema},
  securitySchemes: {'bearerAuth': OpenAPIRef.inline(bearerScheme)},
);
