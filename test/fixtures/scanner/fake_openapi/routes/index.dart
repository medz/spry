import 'package:spry/spry.dart';

import '../shared/fake_openapi.dart';

final openapi = OpenAPI(
  summary: 'Fake',
  globalComponents: OpenAPIComponents(
    schemas: {
      'User': {'type': 'object'},
    },
  ),
);

Response handler(Event event) => Response('fake');
