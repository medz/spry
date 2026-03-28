import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Create a user',
  tags: ['users'],
  requestBody: OpenAPIRef.inline(
    OpenAPIRequestBody(
      required: true,
      content: {
        'application/json': OpenAPIMediaType(
          schema: OpenAPISchema.object(
            {'name': OpenAPISchema.string()},
            requiredProperties: ['name'],
          ),
        ),
      },
    ),
  ),
  responses: {
    '201': OpenAPIRef.inline(
      OpenAPIResponse(
        description: 'Created user',
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

Future<Response> handler(Event event) async {
  final payload = await event.request.json<Object?>();
  final name = switch (payload) {
    {'name': final String name} => name,
    _ => 'Anonymous',
  };

  return Response.json({'id': 'u_3', 'name': name}, ResponseInit(status: 201));
}
