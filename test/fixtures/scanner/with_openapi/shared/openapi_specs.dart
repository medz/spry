import 'package:spry/openapi.dart';

final homeOpenApi = OpenAPI(
  summary: 'Home',
  deprecated: false,
  tags: ['site', 'home'],
  responses: {
    '200': {'description': 'OK'},
  },
);
