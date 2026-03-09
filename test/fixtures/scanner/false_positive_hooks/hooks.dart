class Lifecycle {
  Future<void> onStart(Object context) async {}
}

Future<void> boot() async {
  // TODO: wire onStart(context) later.
  const message = 'onStop(';
  await Lifecycle().onStart(Object());
  /* onError(context, stackTrace) */
  print(message);
}
