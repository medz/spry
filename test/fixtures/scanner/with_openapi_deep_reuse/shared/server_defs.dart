import 'package:spry/openapi.dart';

final regionVariable = OpenAPIServerVariable(
  defaultValue: 'cn',
  values: ['cn', 'us'],
);

final servers = [
  OpenAPIServer(
    url: 'https://{region}.example.com',
    variables: {'region': regionVariable},
  ),
];
