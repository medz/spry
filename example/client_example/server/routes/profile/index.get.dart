import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Read profile',
  tags: ['profile'],
  parameters: [
    .inline(.header('x-api-key', required: true, schema: .string())),
    .inline(.header('x-request-id', schema: .string())),
    .inline(.header('x-starts-at', schema: .string(format: 'date-time'))),
  ],
);

Response handler(Event event) => .json({
  'x-api-key': event.headers.get('x-api-key'),
  'x-request-id': event.headers.get('x-request-id'),
  'x-starts-at': event.headers.get('x-starts-at'),
});
