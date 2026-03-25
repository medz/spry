import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    openapi: OpenAPIConfig(
      document: OpenAPIDocumentConfig(
        info: OpenAPIInfo(title: 'Fixture API', version: '1.0.0'),
      ),
    ),
  );
}
