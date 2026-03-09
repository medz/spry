import 'package:ht/ht.dart' show Request, Response;
import 'package:osrv/osrv.dart' show RequestContext;
import 'public_runtime_stub.dart'
    if (dart.library.io) 'public_runtime_io.dart'
    if (dart.library.js_interop) 'public_runtime_js.dart'
    as runtime;

/// Resolves and serves a static asset for the incoming request.
Future<Response?> servePublicAsset(
  Request request,
  RequestContext context, {
  String? publicDir,
}) async {
  if (request.method != 'GET' && request.method != 'HEAD') {
    return null;
  }

  final root = _normalizePublicDir(publicDir);
  if (root == null) {
    return null;
  }

  for (final candidate in _publicCandidates(request.url.path)) {
    final normalized = _normalizePublicCandidate(candidate);
    if (!_isSafePublicPath(normalized)) {
      continue;
    }

    final asset = await runtime.resolvePublicAsset(
      request,
      context,
      publicDir: root,
      relativePath: normalized,
      includeBody: request.method != 'HEAD',
    );
    if (asset == null) {
      continue;
    }

    final headers = asset.headers.clone();
    if (!headers.has('content-type')) {
      headers.set('content-type', _mimeTypeFor(normalized));
    }

    if (request.method == 'HEAD') {
      return Response.empty(
        status: asset.status,
        statusText: asset.statusText,
        headers: headers,
        url: asset.url,
        redirected: asset.redirected,
      );
    }
    return Response(
      body: asset.body,
      status: asset.status,
      statusText: asset.statusText,
      headers: headers,
      url: asset.url,
      redirected: asset.redirected,
    );
  }

  return null;
}

/// Normalizes a configured public directory path.
String? normalizePublicDir(String? publicDir) => _normalizePublicDir(publicDir);

String? _normalizePublicDir(String? publicDir) {
  if (publicDir == null) {
    return null;
  }

  final trimmed = publicDir.trim();
  if (trimmed.isEmpty) {
    return null;
  }

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
  return switch (_extensionOf(path)) {
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

String _normalizePublicCandidate(String input) {
  input = input.replaceAll('\\', '/');
  final parts = <String>[];
  for (final segment in input.split('/')) {
    if (segment.isEmpty || segment == '.') {
      continue;
    }
    if (segment == '..') {
      if (parts.isNotEmpty) {
        parts.removeLast();
      } else {
        return '../';
      }
      continue;
    }
    parts.add(segment);
  }
  return parts.join('/');
}

String _extensionOf(String path) {
  final slashIndex = path.lastIndexOf('/');
  final dotIndex = path.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex <= slashIndex) {
    return '';
  }
  return path.substring(dotIndex).toLowerCase();
}
