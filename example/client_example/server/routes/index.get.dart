import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'List users',
  tags: ['users'],
  responses: {
    '200': .inline(
      .new(
        description: 'User list',
        content: {
          'application/json': .new(
            schema: .array(
              .object({
                'id': .string(description: 'Stable user identifier.'),
                'name': .string(),
              }),
            ),
          ),
        },
      ),
    ),
  },
);

Response handler(Event event) => .json([
  {'id': 'u_1', 'name': 'Ada'},
  {'id': 'u_2', 'name': 'Linus'},
]);
