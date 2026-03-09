@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:block/block.dart' as block;
import 'package:ht/ht.dart' show Headers, Request;
import 'package:osrv/osrv.dart' show RequestContext;
import 'package:web/web.dart' as web;

import 'public_asset.dart';

@JS('Bun')
external JSObject? get _bunGlobal;

extension type _NodeFsModule._(JSObject _) implements JSObject {}
extension type _NodeFsStats._(JSObject _) implements JSObject {
  external JSFunction get isFile;
  external JSNumber get size;
}
extension type _BunGlobal._(JSObject _) implements JSObject {
  @JS('file')
  external JSFunction? get file;
}

Future<_NodeFsModule?>? _nodeFsModuleOperation;
Future<_NodeFsModule?>? _nodeFsPromisesOperation;

/// Resolves a static asset for JavaScript runtimes such as Node and Bun.
Future<PublicAsset?> resolvePublicAsset(
  Request request,
  RequestContext context, {
  required String? publicDir,
  required String relativePath,
  required bool includeBody,
}) async {
  switch (context.runtime.name) {
    case 'node':
    case 'bun':
      return _resolveNodeAsset(
        request,
        runtime: context.runtime.name,
        publicDir: publicDir,
        relativePath: relativePath,
        includeBody: includeBody,
      );
  }

  return null;
}

Future<PublicAsset?> _resolveNodeAsset(
  Request request, {
  required String runtime,
  required String? publicDir,
  required String relativePath,
  required bool includeBody,
}) async {
  if (publicDir == null) {
    return null;
  }

  final resolvedPath = _resolvePublicPath(publicDir, relativePath);
  if (resolvedPath == null) {
    return null;
  }

  final stats = await _statNodePath(resolvedPath);
  if (stats == null || !_callJsBool(stats.isFile, stats)) {
    return null;
  }

  final headers = Headers({'content-length': '${stats.size.toDartInt}'});
  if (!includeBody) {
    return PublicAsset(headers: headers, url: request.url);
  }

  final blob = await _loadNativeBlob(runtime, resolvedPath);
  if (blob == null) {
    return null;
  }

  final type = blob.type;
  final body = block.Block([
    blob,
  ], type: type.isEmpty ? 'application/octet-stream' : type);
  return PublicAsset(body: body, headers: headers, url: request.url);
}

bool _callJsBool(JSFunction fn, JSObject target) {
  return (fn.callAsFunction(target) as JSBoolean).toDart;
}

String? _resolvePublicPath(String publicDir, String relativePath) {
  final rootPath = _normalizeNativePath(publicDir);
  final targetPath = _normalizeNativePath('$publicDir/$relativePath');
  if (!_isWithinNativePath(rootPath, targetPath)) {
    return null;
  }
  return targetPath;
}

String _normalizeNativePath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final parts = <String>[];
  var prefix = '';

  if (normalized.startsWith('//')) {
    prefix = '//';
  } else if (normalized.length >= 2 && normalized[1] == ':') {
    prefix = normalized.substring(0, 2);
  } else if (normalized.startsWith('/')) {
    prefix = '/';
  }

  final startIndex = prefix == '//'
      ? 2
      : (prefix.isNotEmpty ? prefix.length : 0);
  for (final segment in normalized.substring(startIndex).split('/')) {
    if (segment.isEmpty || segment == '.') {
      continue;
    }
    if (segment == '..') {
      if (parts.isEmpty) {
        parts.add('..');
      } else if (parts.last != '..') {
        parts.removeLast();
      } else {
        parts.add('..');
      }
      continue;
    }
    parts.add(segment);
  }

  final body = parts.join('/');
  if (prefix.isEmpty) {
    return body.isEmpty ? '.' : body;
  }
  if (body.isEmpty) {
    return prefix;
  }
  if (prefix == '/' || prefix == '//') {
    return '$prefix$body';
  }
  return '$prefix/$body';
}

bool _isWithinNativePath(String rootPath, String targetPath) {
  if (targetPath == rootPath) {
    return true;
  }

  final normalizedRoot = rootPath.endsWith('/') ? rootPath : '$rootPath/';
  return targetPath.startsWith(normalizedRoot);
}

Future<web.Blob?> _loadNativeBlob(String runtime, String path) async {
  try {
    switch (runtime) {
      case 'bun':
        final bun = _bunGlobal;
        final file = bun == null ? null : _BunGlobal._(bun).file;
        if (file == null) {
          return null;
        }
        return file.callAsFunction(bun, path.toJS) as web.Blob;
      case 'node':
        final fs = await _loadNodeFsModule();
        if (fs == null) {
          return null;
        }
        final openAsBlob = fs.getProperty<JSFunction?>('openAsBlob'.toJS);
        if (openAsBlob == null) {
          return null;
        }
        final result = openAsBlob.callAsFunction(fs, path.toJS);
        if (result == null) {
          return null;
        }
        return await (result as JSPromise<web.Blob>).toDart;
    }
  } catch (_) {
    return null;
  }

  return null;
}

Future<_NodeFsStats?> _statNodePath(String path) async {
  final fs = await _loadNodeFsPromisesModule();
  if (fs == null) {
    return null;
  }

  final stat = fs.getProperty<JSFunction?>('stat'.toJS);
  if (stat == null) {
    return null;
  }

  try {
    final result = stat.callAsFunction(fs, path.toJS);
    if (result == null) {
      return null;
    }
    final value = await (result as JSPromise<JSAny?>).toDart;
    if (value == null) {
      return null;
    }
    return _NodeFsStats._(value as JSObject);
  } catch (_) {
    return null;
  }
}

Future<_NodeFsModule?> _loadNodeFsPromisesModule() {
  final existing = _nodeFsPromisesOperation;
  if (existing != null) {
    return existing;
  }

  final operation = () async {
    try {
      final module = await importModule('node:fs/promises'.toJS).toDart;
      return _NodeFsModule._(module);
    } catch (_) {
      return null;
    }
  }();
  _nodeFsPromisesOperation = operation;
  return operation;
}

Future<_NodeFsModule?> _loadNodeFsModule() {
  final existing = _nodeFsModuleOperation;
  if (existing != null) {
    return existing;
  }

  final operation = () async {
    try {
      final module = await importModule('node:fs'.toJS).toDart;
      return _NodeFsModule._(module);
    } catch (_) {
      return null;
    }
  }();
  _nodeFsModuleOperation = operation;
  return operation;
}
