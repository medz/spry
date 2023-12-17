import '../dev/spry.dart';

final app = Application();

void main(List<String> args) {
  app.get('/', (event) {
    return Response(null);
  });

  app.group(path: '/api', (routes) {
    routes.get('/users', (event) {
      return Response(null);
    });
  });
}
