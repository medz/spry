import 'package:spry/osrv.dart' as osrv;
import 'package:test/test.dart';

void main() {
  test('re-exports osrv public API', () {
    final context = osrv.RequestContext(
      runtime: const osrv.RuntimeInfo(name: 'test', kind: 'server'),
      capabilities: const osrv.RuntimeCapabilities(
        streaming: true,
        websocket: false,
        fileSystem: true,
        backgroundTask: true,
        rawTcp: false,
        nodeCompat: false,
      ),
      onWaitUntil: (_) {},
    );

    expect(context.runtime.name, 'test');
  });
}
