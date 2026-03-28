// ignore_for_file: file_names

import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final OpenAPI openapi = .new(
  summary: 'Get a user by id',
  tags: ['users'],
  parameters: [
    .inline(
      .path(
        'id',
        schema: .string(description: 'Stable user identifier.'),
        description: 'Unique user identifier.',
      ),
    ),
  ],
  responses: {
    '200': .inline(
      .new(
        description: 'User payload',
        content: {
          'application/json': .new(
            schema: .object({
              'id': .string(description: 'Stable user identifier.'),
              'name': .string(),
            }),
          ),
        },
      ),
    ),
  },
);

Response handler(Event event) =>
    Response.json({'id': event.params.required('id'), 'name': 'Ada'});
