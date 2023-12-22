```dart
final app = Application();

app.get('/', (event) => 'Hello World!');
app.group(path: '/api', (router) {
    router.get('/users', (event) => 'Hello World!');
});
app.grouped(path: '/demo').get('/users', (event) => 'Hello World!');

app.servers.current;
app.servers.configuration.hostname = '127.0.0.1';
app.servers.provide(otherProvider);
app.servers.use((app) => server);

app.clients.current;
app.clients.configuration
app.clients.provide(otherProvider);
app.clients.use((app) => client);

app.collection(new UserController());

app.middleware.use(otherMiddleware);
app.middleware.resolve();

app.logger.info('Hello World!');

app.run();
app.responder.current;
app.responder.use(OtherResponder());
```
