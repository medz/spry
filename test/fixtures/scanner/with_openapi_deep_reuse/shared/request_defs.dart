import 'package:spry/openapi.dart';

import 'schema_leaf.dart' as schemas;

final createUserRequestBody = OpenAPIRef.inline(
  OpenAPIRequestBody(
    required: true,
    content: {
      'application/json': OpenAPIMediaType(schema: schemas.createUserSchema),
    },
  ),
);
