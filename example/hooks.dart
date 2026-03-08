import 'package:spry/spry.dart';

Future<void> onStart(ServerLifecycleContext context) async {
  print('Spry example started: ${context.runtime.name}');
}

Future<Response> onError(
  Object error,
  StackTrace stackTrace,
  Request request,
  RequestContext context,
) async {
  return Response.json({
    'error': '$error',
    'path': request.url.path,
    'runtime': context.runtime.name,
  }, status: 500);
}
