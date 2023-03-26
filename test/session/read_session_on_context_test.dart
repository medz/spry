import 'package:spry/session.dart';
import 'package:spry/spry.dart';
import 'package:spry/src/session/internal/info.dart';
import 'package:test/test.dart';

void main() {
  final info = Info(
    identifierGenerator: () async => 'session-id',
    identifier: '',
  );
  final context = Context()
    ..[Session] = Session(
      adapter: const MemorySessionAdapter(),
      info: info,
    );

  test('read session on context', () async {
    expect(context.session.identifier, isEmpty);

    await context.session.destroy();

    expect(context.session.identifier, 'session-id');
  });
}
