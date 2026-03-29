import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

import '../../shared/input_specs.dart';

final openapi = OpenAPI(
  summary: 'Create a participant payload from a shared request body',
  tags: ['participants'],
  globalComponents: participantComponents,
  requestBody: .ref('#/components/requestBodies/ParticipantPayload'),
);

Future<Response> handler(Event event) async {
  final payload = await event.request.json();
  return .json(payload);
}
