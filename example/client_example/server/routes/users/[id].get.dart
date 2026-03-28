// ignore_for_file: file_names

import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Get a user by id',
  tags: ['users'],
  parameters: [
    OpenAPIRef.inline(
      OpenAPIParameter.path(
        'id',
        schema: OpenAPISchema.string(
          description: 'Stable user identifier.',
        ),
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
            schema: OpenAPISchema.object({
              'id': OpenAPISchema.string(
                description: 'Stable user identifier.',
              ),
              'name': OpenAPISchema.string(),
            }),
          ),
        },
      ),
    ),
  },
);

Response handler(Event event) =>
    Response.json({'id': event.params.required('id'), 'name': 'Ada'});
