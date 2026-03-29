import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

typedef OtherOAS = OpenAPI;

final openapi = OtherOAS(
  summary: 'Alias default constructor',
  responses: {'200': OpenAPIRef.inline(OpenAPIResponse(description: 'OK'))},
);

Response handler(Event event) => Response('ok');
