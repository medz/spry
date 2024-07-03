import '../event.dart';

T getRawEvent<T extends RawEvent>(Event event) {
  return switch (event.raw) {
    T event => event,
    _ => throw TypeError(),
  };
}
