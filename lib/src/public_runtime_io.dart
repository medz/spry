import 'dart:io' as io;

import 'package:ht/ht.dart' show Headers, Request;
import 'package:osrv/osrv.dart' show RequestContext;
import 'package:path/path.dart' as p;

import 'public_asset.dart';

Future<PublicAsset?> resolvePublicAsset(
  Request request,
  RequestContext context, {
  required String? publicDir,
  required String relativePath,
  required bool includeBody,
}) async {
  if (publicDir == null) {
    return null;
  }

  final file = io.File(p.join(publicDir, relativePath));
  final stat = await file.stat();
  if (stat.type != io.FileSystemEntityType.file) {
    return null;
  }

  return PublicAsset(
    body: includeBody ? file.openRead() : null,
    headers: Headers({'content-length': '${stat.size}'}),
    url: request.url,
  );
}
