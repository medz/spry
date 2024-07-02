Future<void> Function()? _effect;

Future<void> next() async {
  await _effect?.call();
  _effect = null;
}

void setNext(Future<void> Function() next) {
  _effect = next;
}
