@JS()
library;

import 'dart:js_interop';

import 'package:block/block.dart' as block;
import 'package:ht/ht.dart' show Headers, Request;
import 'package:path/path.dart' as p;
import 'package:web/web.dart' as web;

import '../../osrv.dart' show RequestContext;
import 'native_path.dart';
import 'public_asset.dart';

@JS('Bun')
external JSObject? get _bunGlobal;
@JS('process')
external JSObject? get _processGlobal;

extension type _NodeFsModule._(JSObject _) implements JSObject {
  external JSPromise<_NodeFsStats> stat(JSString path);
  external JSPromise<web.Blob> openAsBlob(JSString path);
}

extension type _NodeFsStats._(JSObject _) implements JSObject {
  external bool isFile();
  external JSNumber get size;
}

extension type _ProcessGlobal._(JSObject _) implements JSObject {
  external JSString? get platform;
}

extension type _BunGlobal._(JSObject _) implements JSObject {
  @JS('file')
  external JSFunction? get file;
}

Future<_NodeFsModule?>? _nodeFsOperation;

Future<_NodeFsModule?> _loadNodeFsModule() => _nodeFsOperation ??= () async {
  try {
    return _NodeFsModule._(await importModule('node:fs/promises'.toJS).toDart);
  } catch (_) {
    return null;
  }
}();

/// Resolves a static asset for JavaScript runtimes such as Node and Bun.
Future<PublicAsset?> resolvePublicAsset(
  Request request,
  RequestContext context, {
  required String? publicDir,
  required String relativePath,
  required bool includeBody,
  Uri? requestUri,
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
        requestUri: requestUri,
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
  Uri? requestUri,
}) async {
  if (publicDir == null) {
    return null;
  }

  final resolvedPath = resolveNativeChildPath(
    publicDir,
    relativePath,
    style: _nativePathStyle(),
  );
  if (resolvedPath == null) {
    return null;
  }

  final fs = await _loadNodeFsModule();
  if (fs == null) {
    return null;
  }

  final _NodeFsStats stats;
  try {
    stats = await fs.stat(resolvedPath.toJS).toDart;
  } catch (_) {
    return null;
  }

  if (!stats.isFile()) {
    return null;
  }

  final uri = requestUri ?? Uri.parse(request.url);
  final headers = Headers({'content-length': '${stats.size.toDartInt}'});

  if (!includeBody) {
    return PublicAsset(headers: headers, url: uri);
  }

  final blob = await _loadNativeBlob(runtime, fs, resolvedPath);
  if (blob == null) {
    return null;
  }

  final type = blob.type;
  final body = block.Block([
    blob,
  ], type: type.isEmpty ? 'application/octet-stream' : type);
  return PublicAsset(body: body, headers: headers, url: uri);
}

p.Style _nativePathStyle() {
  final process = _processGlobal;
  if (process == null) {
    return p.Style.posix;
  }

  final platform = _ProcessGlobal._(process).platform?.toDart;
  return platform == 'win32' ? p.Style.windows : p.Style.posix;
}

Future<web.Blob?> _loadNativeBlob(
  String runtime,
  _NodeFsModule fs,
  String path,
) async {
  try {
    switch (runtime) {
      case 'bun':
        final bun = _bunGlobal;
        final file = bun == null ? null : _BunGlobal._(bun).file;
        if (file == null) return null;
        return file.callAsFunction(bun, path.toJS) as web.Blob;
      case 'node':
        return await fs.openAsBlob(path.toJS).toDart;
    }
  } catch (_) {
    return null;
  }
  return null;
}
