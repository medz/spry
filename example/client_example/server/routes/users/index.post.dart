import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Create a user',
  tags: ['users'],
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'application/json': .new(
          schema: .object({'name': .string()}, requiredProperties: ['name']),
        ),
      },
    ),
  ),
  responses: {
    '201': .inline(
      .new(
        description: 'Created user',
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

Future<Response> handler(Event event) async {
  final payload = await event.request.json();
  final name = switch (payload) {
    {'name': final String name} => name,
    _ => 'Anonymous',
  };

  return .json({'id': 'u_3', 'name': name}, .new(status: 201));
}
