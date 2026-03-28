import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final OpenAPIMediaType jsonMediaType = .new(
  schema: .array(.object({'id': .string()})),
);

final OpenAPIRef<OpenAPISecurityScheme> apiKeyScheme = .inline(
  OpenAPISecurityScheme.apiKey(name: 'x-api-key', location: .header),
);

final OpenAPIRef<OpenAPIResponse> okResponse = .inline(
  .new(description: 'OK', content: {'application/json': jsonMediaType}),
);

final OpenAPI openapi = .new(
  summary: 'Home',
  globalComponents: OpenAPIComponents(
    securitySchemes: {'apiKey': apiKeyScheme},
  ),
  responses: {'200': okResponse},
);

Response handler(Event event) => Response('home');
