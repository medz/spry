import 'package:ht/ht.dart' show Request;
import 'package:osrv/osrv.dart' show RequestContext;

import 'public_asset.dart';

Future<PublicAsset?> resolvePublicAsset(
  Request request,
  RequestContext context, {
  required String? publicDir,
  required String relativePath,
  required bool includeBody,
}) async {
  return null;
}
