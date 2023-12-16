import '../dev/spry.dart';

final app = Application();

void main(List<String> args) {
  app.routes.get('/', (event) {
    return Response(null);
  });

  app.routes.group('/api', (routes) {
    routes.get('/users', (event) {
      return Response(null);
    });
  });

  print(app.routes.all);
}
