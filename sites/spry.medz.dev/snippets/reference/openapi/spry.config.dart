import 'package:spry/config.dart';
import 'package:spry/openapi.dart';

void main() {
  defineSpryConfig(
    openapi: OpenAPIConfig(
      document: OpenAPIDocumentConfig(
        info: OpenAPIInfo(
          title: 'Spry API',
          version: '1.0.0',
          description: 'Public HTTP API',
        ),
        components: OpenAPIComponents(
          schemas: {
            'User': OpenAPISchema.object({
              'id': OpenAPISchema.string(),
            }),
          },
          pathItems: {
            'UserCreatedWebhook': OpenAPIPathItem(
              post: OpenAPIOperation(
                responses: {
                  '202': OpenAPIRef.inline(
                    OpenAPIResponse(description: 'Accepted'),
                  ),
                },
              ),
            ),
          },
        ),
        webhooks: {
          'userCreated': OpenAPIPathItem(
            $ref: '#/components/pathItems/UserCreatedWebhook',
          ),
        },
      ),
      output: OpenAPIOutput.route('openapi.json'),
      componentsMergeStrategy: OpenAPIComponentsMergeStrategy.strict,
    ),
  );
}
