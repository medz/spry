import 'package:spry/config.dart';
import 'package:spry/openapi.dart';

void main() {
  defineSpryConfig(
    openapi: OpenAPIConfig(
      document: OpenAPIDocumentConfig(
        info: OpenAPIInfo(title: 'Fixture API', version: '1.0.0'),
        webhooks: {
          'userCreated': OpenAPIPathItem(
            $ref: '#/components/pathItems/UserCreated',
          ),
        },
      ),
    ),
  );
}
