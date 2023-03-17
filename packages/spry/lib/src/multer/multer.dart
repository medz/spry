import 'dart:async';
import 'dart:io';

import 'package:mime/mime.dart';

import '../context.dart';
import '../middleware.dart';
import '../request.dart';
import '_internal/file_impl.dart';
import 'file.dart';
import 'multipart.dart';

part '_internal/multer_impl.dart';

/// Spry framework [Multer] middleware.
///
/// The middleware parses a multipart/form-data request and makes the parsed
/// data available on the [Request] object.
abstract class Multer {
  const Multer._internal();

  /// Creates a new [Multer] middleware.
  const factory Multer() = _MulterImpl;

  /// Handles the request.
  FutureOr<void> call(Context context, Next next) {
    // Register the [Multer] instance on the [Context].
    context[Multer] = this;

    return next();
  }

  /// Find or create a [Multer] instance on the [Context].
  static Multer of(Context context) {
    if (!context.contains(Multer)) {
      context[Multer] = const Multer();
    }

    return context[Multer];
  }

  /// Create a [Stream] of [List] of [int]s into a [Multipart] object.
  Future<Multipart> createMultipart(String boundary, Request request);
}
