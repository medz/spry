import 'package:spry/openapi.dart';

import 'schema_leaf.dart' as schemas;

final createdExample = OpenAPIRef.inline(
  OpenAPIExample(
    summary: 'Created user example',
    value: {'id': 'u_1', 'name': 'Ada'},
  ),
);

final locationHeader = OpenAPIRef.inline(
  OpenAPIHeader(
    schema: OpenAPISchema.string(),
    description: 'Canonical user URL.',
  ),
);

final selfLink = OpenAPIRef.inline(
  OpenAPILink(
    operationId: 'getUser',
    parameters: {'id': '\$response.body#/id'},
  ),
);

final createdResponse = OpenAPIRef.inline(
  OpenAPIResponse(
    description: 'Created user',
    headers: {'Location': locationHeader},
    content: {
      'application/json': OpenAPIMediaType(
        schema: schemas.userSchema,
        examples: {'default': createdExample},
      ),
    },
    links: {'self': selfLink},
  ),
);

final responses = {'201': createdResponse};
