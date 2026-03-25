import 'package:ht/ht.dart'
    show Headers, HttpMethod, Request, Response, ResponseInit;
import 'package:path/path.dart' as p;

import '../osrv.dart' show RequestContext;
import 'public_runtime_stub.dart'
    if (dart.library.io) 'public_runtime_io.dart'
    if (dart.library.js_interop) 'public_runtime_js.dart'
    as runtime;

/// Resolves and serves a static asset for the incoming request.
Future<Response?> servePublicAsset(
  Request request,
  RequestContext context, {
  String? publicDir,
  Uri? requestUri,
}) async {
  if (request.method != HttpMethod.get && request.method != HttpMethod.head) {
    return null;
  }

  final root = normalizePublicDir(publicDir);
  if (root == null) {
    return null;
  }

  final uri = requestUri ?? Uri.parse(request.url);

  for (final candidate in _publicCandidates(uri.path)) {
    final normalized = p.posix.normalize(candidate);
    if (!_isSafePublicPath(normalized)) {
      continue;
    }

    final asset = await runtime.resolvePublicAsset(
      request,
      context,
      publicDir: root,
      relativePath: normalized,
      includeBody: request.method != HttpMethod.head,
      requestUri: uri,
    );
    if (asset == null) {
      continue;
    }

    final headers = Headers(asset.headers.entries());
    if (!headers.has('content-type')) {
      headers.set('content-type', _mimeTypeFor(normalized));
    }

    final init = ResponseInit(
      status: asset.status,
      statusText: asset.statusText,
      headers: headers,
    );

    if (request.method == HttpMethod.head) {
      return Response(null, init);
    }
    return Response(asset.body, init);
  }

  return null;
}

/// Normalizes a configured public directory path.
String? normalizePublicDir(String? publicDir) {
  final trimmed = publicDir?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed.replaceAll('\\', '/');
}

Iterable<String> _publicCandidates(String path) sync* {
  if (path == '/') {
    yield 'index.html';
    return;
  }

  final relative = path.startsWith('/') ? path.substring(1) : path;
  if (relative.isEmpty) {
    yield 'index.html';
    return;
  }

  yield relative;
  if (relative.endsWith('/')) {
    yield '${relative}index.html';
  } else {
    yield '$relative/index.html';
  }
}

bool _isSafePublicPath(String path) {
  return path.isNotEmpty &&
      path != '.' &&
      path != '..' &&
      !path.contains('\\') &&
      !path.startsWith('../') &&
      !path.startsWith('/');
}

String _mimeTypeFor(String path) {
  return switch (p.extension(path).toLowerCase()) {
    '.html' || '.htm' => 'text/html; charset=utf-8',
    '.css' => 'text/css; charset=utf-8',
    '.js' || '.mjs' => 'text/javascript; charset=utf-8',
    '.json' => 'application/json; charset=utf-8',
    '.txt' => 'text/plain; charset=utf-8',
    '.xml' => 'application/xml; charset=utf-8',
    '.svg' => 'image/svg+xml',
    '.png' => 'image/png',
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.gif' => 'image/gif',
    '.webp' => 'image/webp',
    '.ico' => 'image/x-icon',
    '.pdf' => 'application/pdf',
    '.wasm' => 'application/wasm',
    '.map' => 'application/json; charset=utf-8',
    _ => 'application/octet-stream',
  };
}
