import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

extension type FakeMediaType._(Map<String, Object?> _)
    implements OpenAPIMediaType {
  factory FakeMediaType({Object? schema}) =>
      FakeMediaType._({'schema': ?schema});
}

extension type FakeOkResponseRef._(Object? _)
    implements OpenAPIRef<OpenAPIResponse> {
  factory FakeOkResponseRef.inline(Object? value) => FakeOkResponseRef._(value);
}

extension type FakeOAS._(Map<String, Object?> _) implements OpenAPI {
  factory FakeOAS({String? summary, Map<String, Object?>? responses}) =>
      FakeOAS._({'summary': ?summary, 'responses': ?responses});
}

final fakeMediaType = FakeMediaType(
  schema: {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
    },
  },
);

final fakeOkResponse = FakeOkResponseRef.inline({
  'description': 'OK',
  'content': {'application/json': fakeMediaType},
});

final openapi = FakeOAS(
  summary: 'Fake implementation constructor',
  responses: {'200': fakeOkResponse},
);

Response handler(Event event) => Response('fake');
