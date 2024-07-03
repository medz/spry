import 'context.dart';

abstract interface class RawEvent {
  Context get context;
}

extension type const Event(RawEvent raw) {}
