import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

extension type FakeMediaType._(Map<String, Object?> _)
    implements OpenAPIMediaType {
  factory FakeMediaType({OpenAPISchema? schema}) =>
      FakeMediaType._({'schema': ?schema});
}

extension type FakeOAS._(Map<String, Object?> _) implements OpenAPI {
  factory FakeOAS({
    String? summary,
    Map<String, OpenAPIRef<OpenAPIResponse>>? responses,
  }) => FakeOAS._({'summary': ?summary, 'responses': ?responses});
}

final FakeMediaType jsonMediaType = FakeMediaType(
  schema: OpenAPISchema.object({'id': OpenAPISchema.string()}),
);

final openapi = FakeOAS(
  summary: 'Fake representation subtype constructor',
  responses: {
    '200': OpenAPIRef.inline(
      OpenAPIResponse(
        description: 'OK',
        content: {'application/json': jsonMediaType},
      ),
    ),
  },
);

Response handler(Event event) => Response('fake');
