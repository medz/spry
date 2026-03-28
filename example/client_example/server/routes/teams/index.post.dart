import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

import '../../shared/input_specs.dart';

final openapi = OpenAPI(
  summary:
      'Create a team payload with mixed shared and inline participant shapes',
  tags: ['teams'],
  globalComponents: participantComponents,
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'application/json': .new(
          schema: .object(
            {
              'lead': .ref('#/components/schemas/Participant'),
              'backup': .object(
                {
                  'name': .string(),
                  'address': .ref('#/components/schemas/Address'),
                },
                requiredProperties: ['name', 'address'],
              ),
              'members': .array(.ref('#/components/schemas/Participant')),
            },
            requiredProperties: ['lead', 'backup'],
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
