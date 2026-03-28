import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

typedef OkResponseRef = OpenAPIRef<OpenAPIResponse>;

final OkResponseRef okResponse = .inline(
  .new(
    description: 'OK',
    content: {
      'application/json': .new(schema: .object({'id': .string()})),
    },
  ),
);

final OpenAPI openapi = .new(
  summary: 'Ref alias constructor',
  responses: {'200': okResponse},
);

Response handler(Event event) => Response('ok');
