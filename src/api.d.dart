api() async {
  final app = createSpry();
  app.use((event, next) {});
  app.use(method: 'get', (event, next) {});
  app.use(path: '/demo', (event, next) {});
  app.use(method: "post", path: '/haha', (event, next) {});
  app.on(path: '/', (event) {});
  app.get('/a', (event) {});

  final server = app.serve(
    hostname: '127.0.0.1',
    port: 3000,
  );
  await server.ready();

  print('🎉 Spry server lisen at http://127.0.0.1:3000');
}
