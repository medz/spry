import 'package:spry/spry.dart';

import 'package:spry/src/locals/locals.dart';

class ExampleEvent implements Event {
  @override
  final Locals locals = LocalsImpl();
}

void main() async {
  final app = Spry();

  app.use((event) {
    print(1);
  });

  app.use((event) async {
    final res = await next(event);
    print(2);

    return res;
  });

  app.use((event) {
    print(3);
  });

  app.use((event) {
    print(4);

    // 中断向内嵌套，返回 Response 或者其他任何信息
    return const Response(null);
  });

  app.use((event) {
    print('Unable to execute');
  });

  final handle = app.handler.handle;
  final event = ExampleEvent();

  event.locals.set(Spry, app);

  await handle(event);
}
