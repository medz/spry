import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

import '../../shared/input_specs.dart';

final openapi = OpenAPI(
  summary: 'Create a project payload from shared participant components',
  tags: ['projects'],
  globalComponents: participantComponents,
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'application/json': .new(
          schema: .object(
            {
              'owner': .ref('#/components/schemas/Participant'),
              'reviewer': .ref('#/components/schemas/Participant'),
              'watchers': .array(.ref('#/components/schemas/Participant')),
            },
            requiredProperties: ['owner', 'reviewer'],
          ),
        ),
      },
    ),
  ),
);

Future<Response> handler(Event event) async {
  final payload = await event.request.json();
  return .json(payload);
}
