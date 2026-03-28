import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    client: ClientConfig(
      output: '.spry/client',
      endpoint: 'https://api.example.com',
      headers: Headers({'x-client': 'web', 'x-version': '1'}),
    ),
  );
}
