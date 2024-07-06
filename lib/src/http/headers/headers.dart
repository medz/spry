abstract interface class Headers implements Iterable<(String, String)> {
  const factory Headers([Iterable<(String, String)> init]) = _HeadersImpl;
}

final class _HeadersImpl extends Iterable<(String, String)> implements Headers {
  const _HeadersImpl([this.locals = const []]);

  final Iterable<(String, String)> locals;

  @override
  // TODO: implement iterator
  Iterator<(String, String)> get iterator => locals.iterator;
}
