import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

extension type OtherOAS._(OpenAPI _) {}

final openapi = OtherOAS._(
  OpenAPI(
    summary: 'Subtype constructor',
    responses: {
      '200': OpenAPIRef.inline(
        OpenAPIResponse(
          description: 'OK',
          content: {
            'application/json': OpenAPIMediaType(
              schema: OpenAPISchema.object({'id': OpenAPISchema.string()}),
            ),
          },
        ),
      ),
    },
  ),
);

Response handler(Event event) => Response('ok');
