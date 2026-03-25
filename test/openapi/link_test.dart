import 'dart:convert';

import 'package:spry/openapi.dart';
import 'package:test/test.dart';

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

      expect(_decodeJsonValue(link), {
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

      expect(_decodeJsonValue(link), {
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
  });
}

dynamic _decodeJsonValue(dynamic value) => jsonDecode(jsonEncode(value));
