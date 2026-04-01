import 'dart:convert';

import 'package:ht/ht.dart' show Response, ResponseInit;

import '../handler.dart';

/// Creates a route handler that serves a Scalar-powered API reference page.
///
/// [url] may be a local pathname such as `'/openapi.json'` or a full URL such
/// as `'https://api.example.com/openapi.json'`.
Handler defineScalarHandler({
  required String url,
  String title = 'API Reference',
  String? theme,
  String? layout,
}) {
  title = const HtmlEscape(.element).convert(title);
  final config = json.encode({'url': url, 'theme': ?theme, 'layout': ?layout});
  final html =
      '''<!doctype html>
<html>
  <head>
    <title>$title</title>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1" />
  </head>
  <body>
    <div id="app"></div>
    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
    <script>
      Scalar.createApiReference('#app', $config)
    </script>
  </body>
</html>
  ''';
  final init = ResponseInit(
    headers: {'content-type': 'text/html; charset=utf-8'},
  );

  return (_) => Response(html, init);
}
