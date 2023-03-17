import 'package:spry/spry.dart';

import 'multer.dart';
import 'multipart.dart';

/// Multer extension on [Request].
extension SpryMulterExtension on Request {
  /// Find or create a [Multipart] instance on the [Request].
  Future<Multipart> multipart() async {
    // If the [Request] already contains a [Multipart] instance, return it.
    if (context.contains(Multipart)) {
      return context[Multipart];
    }

    final contenType = headers.contentType;
    final boundary = contenType?.parameters['boundary'];

    // If content type is not multipart/form-data and boundary is not present,
    // throw an exception.
    if (contenType?.mimeType.toLowerCase() != 'multipart/form-data' ||
        boundary == null) {
      throw SpryHttpException.badGateway(
        message: 'Content type is not multipart/form-data',
      );
    }

    return context[Multipart] =
        await Multer.of(context).createMultipart(boundary, this);
  }
}
