import 'package:ht/ht.dart' show Request;

import '../../osrv.dart' show RequestContext;
import 'public_asset.dart';

/// Fallback asset resolver for unsupported runtimes.
Future<PublicAsset?> resolvePublicAsset(
  Request request,
  RequestContext context, {
  required String? publicDir,
  required String relativePath,
  required bool includeBody,
  Uri? requestUri,
}) async {
  return null;
}
