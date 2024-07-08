// ignore_for_file: file_names

import 'platform/platform.dart';
import 'platform/platform+create_handler.dart';
import 'platform/platform_handler.dart';
import 'spry.dart';

extension SpryCreatePlatfromHandler<T, R> on Spry {
  PlatformHandler<T, R> createPlatformHandler(Platform<T, R> platform) =>
      platform.createHandler(this);
}
