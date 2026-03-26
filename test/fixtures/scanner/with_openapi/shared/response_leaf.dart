import 'package:spry/openapi.dart';

final okResponse = OpenAPIRef.inline(
  OpenAPIResponse(
    description: 'OK',
    content: {
      'application/json': OpenAPIMediaType(
        schema: OpenAPISchema.array(OpenAPISchema.string()),
      ),
    },
  ),
);
