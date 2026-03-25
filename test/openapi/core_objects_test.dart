import 'dart:convert';

import 'package:spry/openapi.dart';
import 'package:spry/src/openapi/config.dart';
import 'package:test/test.dart';

void main() {
  group('core openapi objects', () {
    test('builds document objects with stable JSON shapes', () {
      final document = OpenAPIDocument(
        info: OpenAPIInfo(
          title: 'Spry API',
          version: '1.0.0',
          summary: 'Core',
          description: 'Document',
          termsOfService: 'https://example.com/terms',
          contact: OpenAPIContact(
            name: 'Spry',
            url: 'https://example.com',
            email: 'team@example.com',
          ),
          license: OpenAPILicense(name: 'MIT', identifier: 'MIT'),
          extensions: {'owner': 'spry'},
        ),
        paths: {
          '/users/{id}': OpenAPIPathItem(
            summary: 'User path',
            get: OpenAPIOperation(summary: 'Get user', operationId: 'getUser'),
            extensions: {'scope': 'users'},
          ),
        },
        components: OpenAPIComponents(
          pathItems: {
            'UserById': OpenAPIPathItem($ref: '#/paths/~1users~1{id}'),
          },
          extensions: {'bucket': 'core'},
        ),
        servers: [
          OpenAPIServer(
            url: 'https://api.example.com/{env}',
            description: 'Primary',
            variables: {
              'env': OpenAPIServerVariable(
                defaultValue: 'prod',
                values: ['prod', 'staging'],
              ),
            },
            extensions: {'region': 'global'},
          ),
        ],
        webhooks: {
          'userCreated': OpenAPIPathItem(
            $ref: '#/components/pathItems/UserById',
          ),
        },
        tags: [
          OpenAPITag(
            name: 'users',
            description: 'User operations',
            externalDocs: OpenAPIExternalDocs(
              url: 'https://example.com/docs/users',
            ),
            extensions: {'group': 'public'},
          ),
        ],
        externalDocs: OpenAPIExternalDocs(
          url: 'https://example.com/docs',
          description: 'Docs',
          extensions: {'kind': 'site'},
        ),
        jsonSchemaDialect: 'https://json-schema.org/draft/2020-12/schema',
        extensions: {'generated-by': 'spry'},
      );

      final json = _decodeJson(document);

      expect(json['openapi'], '3.1.0');
      expect(json['info'], isA<Map<String, dynamic>>());
      expect(json['paths'], {'/users/{id}': isA<Map<String, dynamic>>()});
      expect(json['components'], isA<Map<String, dynamic>>());
      expect(json['servers'], [isA<Map<String, dynamic>>()]);
      expect(json['webhooks'], {'userCreated': isA<Map<String, dynamic>>()});
      expect(json['tags'], [isA<Map<String, dynamic>>()]);
      expect(json['externalDocs'], isA<Map<String, dynamic>>());
      expect(
        json['jsonSchemaDialect'],
        'https://json-schema.org/draft/2020-12/schema',
      );
      expect(json['x-generated-by'], 'spry');
    });

    test('builds refs, path items, operations and components', () {
      final ref = OpenAPIRef<Object>.ref(
        '#/components/responses/Ok',
        summary: 'OK',
        description: 'Shared response',
      );
      final pathItem = OpenAPIPathItem(
        $ref: '#/components/pathItems/UserById',
        head: OpenAPIOperation(summary: 'HEAD'),
      );
      final operation = OpenAPIOperation(
        summary: 'Read user',
        extensions: {'scope': 'users'},
      );
      final routeMetadata = OpenAPI(
        summary: 'Route metadata',
        globalComponents: OpenAPIComponents(pathItems: {'UserById': pathItem}),
      );

      final refJson = _decodeJson(ref);
      final pathItemJson = _decodeJson(pathItem);
      final operationJson = _decodeJson(operation);
      final routeJson = _decodeJson(routeMetadata);

      expect(refJson[r'$ref'], '#/components/responses/Ok');
      expect(refJson['summary'], 'OK');
      expect(refJson['description'], 'Shared response');
      expect(pathItemJson[r'$ref'], '#/components/pathItems/UserById');
      expect(pathItemJson['head'], isA<Map<String, dynamic>>());
      expect(operationJson['x-scope'], 'users');
      expect(
        routeJson['x-spry-openapi-global-components'],
        isA<Map<String, dynamic>>(),
      );
    });

    test('parses document config nested core objects from JSON', () {
      final config = OpenAPIDocumentConfig.fromJson({
        'info': {
          'title': 'Spry API',
          'version': '1.0.0',
          'contact': {'name': 'Team'},
          'license': {'name': 'MIT', 'identifier': 'MIT'},
        },
        'components': {
          'pathItems': {
            'UserById': {r'$ref': '#/paths/~1users~1{id}'},
          },
        },
        'servers': [
          {
            'url': 'https://api.example.com/{env}',
            'variables': {
              'env': {
                'default': 'prod',
                'enum': ['prod'],
              },
            },
          },
        ],
        'webhooks': {
          'userCreated': {r'$ref': '#/components/pathItems/UserById'},
        },
        'tags': [
          {
            'name': 'users',
            'externalDocs': {'url': 'https://example.com/docs/users'},
          },
        ],
        'externalDocs': {'url': 'https://example.com/docs'},
        'jsonSchemaDialect': 'https://json-schema.org/draft/2020-12/schema',
      });

      expect(config.info.contact, isA<OpenAPIContact>());
      expect(config.info.license, isA<OpenAPILicense>());
      expect(config.components, isA<OpenAPIComponents>());
      expect(config.servers, [isA<OpenAPIServer>()]);
      expect(config.webhooks, {'userCreated': isA<OpenAPIPathItem>()});
      expect(config.tags, [isA<OpenAPITag>()]);
      expect(config.externalDocs, isA<OpenAPIExternalDocs>());
      expect(
        config.jsonSchemaDialect,
        'https://json-schema.org/draft/2020-12/schema',
      );
    });

    test('validates license identifier and url as mutually exclusive', () {
      expect(
        () => OpenAPILicense(name: 'MIT', identifier: 'MIT', url: 'https://x'),
        throwsArgumentError,
      );
    });
  });
}

Map<String, dynamic> _decodeJson(dynamic value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
