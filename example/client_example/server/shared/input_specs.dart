import 'package:spry/openapi.dart';

final participantComponents = OpenAPIComponents(
  schemas: {
    'Address': .object(
      {'city': .string(), 'zip': .string()},
      requiredProperties: ['city', 'zip'],
    ),
    'Participant': .object(
      {'name': .string(), 'address': .ref('#/components/schemas/Address')},
      requiredProperties: ['name', 'address'],
    ),
  },
  requestBodies: {
    'ParticipantPayload': .inline(
      .new(
        required: true,
        content: {
          'application/json': .new(
            schema: .ref('#/components/schemas/Participant'),
          ),
        },
      ),
    ),
  },
);
