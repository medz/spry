import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  summary: 'Any user op',
  parameters: [
    OpenAPIRef.inline(
      OpenAPIParameter.path('id', schema: OpenAPISchema.string()),
    ),
  ],
  responses: {'200': OpenAPIRef.inline(OpenAPIResponse(description: 'OK'))},
);

Response handler(Event event) => Response('user-any');
