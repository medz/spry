import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi link', () {
    test('serializes operationId link', () {
      final link = OpenAPILink(
        operationId: 'getUser',
        parameters: {'id': r'$response.body#/id'},
        requestBody: {'source': 'link'},
        description: 'Fetch the linked user',
        server: OpenAPIServer(url: 'https://api.example.com'),
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(link), {
        'operationId': 'getUser',
        'parameters': {'id': r'$response.body#/id'},
        'requestBody': {'source': 'link'},
        'description': 'Fetch the linked user',
        'server': {'url': 'https://api.example.com'},
        'x-source': 'fixture',
      });
    });

    test('serializes operationRef link', () {
      final link = OpenAPILink(operationRef: '#/paths/~1users~1{id}/get');

      expect(decodeJsonValue(link), {
        'operationRef': '#/paths/~1users~1{id}/get',
      });
    });

    test('rejects operationRef and operationId together', () {
      expect(
        () => OpenAPILink(
          operationRef: '#/paths/~1users~1{id}/get',
          operationId: 'getUser',
        ),
        throwsArgumentError,
      );
    });

    test('rejects neither operationRef nor operationId', () {
      expect(() => OpenAPILink(), throwsArgumentError);
    });
  });
}
