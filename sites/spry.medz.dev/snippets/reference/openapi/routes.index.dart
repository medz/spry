import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'List users',
  tags: ['users'],
  responses: {
    '200': OpenAPIRef.inline(
      OpenAPIResponse(
        description: 'OK',
        content: {
          'application/json': OpenAPIMediaType(
            schema: OpenAPISchema.array(
              OpenAPISchema.ref('#/components/schemas/User'),
            ),
          ),
        },
      ),
    ),
  },
);

Response handler(Event event) => Response.json([]);
