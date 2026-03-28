import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Get user',
  parameters: [
    OpenAPIRef.inline(
      OpenAPIParameter.path('id', schema: OpenAPISchema.string()),
    ),
  ],
  responses: {'200': OpenAPIRef.inline(OpenAPIResponse(description: 'OK'))},
);

Response handler(Event event) => Response('user-get');
