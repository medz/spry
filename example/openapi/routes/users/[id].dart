// ignore_for_file: file_names

import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Handle a user by id',
  tags: ['users'],
  parameters: [
    OpenAPIRef.inline(
      OpenAPIParameter.path(
        'id',
        schema: OpenAPISchema.ref('#/components/schemas/UserId'),
        description: 'Unique user identifier.',
      ),
    ),
  ],
  responses: {
    '200': OpenAPIRef.inline(
      OpenAPIResponse(
        description: 'User payload',
        content: {
          'application/json': OpenAPIMediaType(
            schema: OpenAPISchema.ref('#/components/schemas/User'),
          ),
        },
      ),
    ),
  },
);

Response handler(Event event) =>
    Response.json({'id': event.params['id'], 'name': 'Ada'});
