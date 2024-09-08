import '../_constants.dart';
import '../types.dart';

/// Returns RAW event.
T useRaw<T>(Event event) => event.get(kRaw) as T;
