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
          schema: .object(
            {'name': .string(), 'startsAt': .string(format: 'date-time')},
            requiredProperties: ['name', 'startsAt'],
          ),
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
              'startsAt': .string(format: 'date-time'),
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
  final startsAt = switch (payload) {
    {'startsAt': final String startsAt} => startsAt,
    _ => DateTime.now().toIso8601String(),
  };

  return .json({
    'id': 'u_3',
    'name': name,
    'startsAt': startsAt,
  }, .new(status: 201));
}
