import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Search users',
  tags: ['search'],
  parameters: [
    .inline(.query('q', required: true, schema: .string())),
    .inline(.query('page', schema: .integer())),
    .inline(.query('startsAt', schema: .string(format: 'date-time'))),
  ],
);

Response handler(Event event) => .json({
  'q': event.query.get('q'),
  'page': event.query.get('page'),
  'startsAt': event.query.get('startsAt'),
});
