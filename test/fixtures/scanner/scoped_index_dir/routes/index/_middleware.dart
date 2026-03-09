Future<void> middleware(event, next) async {
  await next();
}
