import 'dart:async';

import 'package:spry/src/mcp/mcp_build_state.dart';
import 'package:test/test.dart';

void main() {
  void succeed(McpBuildState state, int generation) => state.succeed(
    generation,
    target: 'vm',
    outputDir: '.spry',
    generatedFileCount: 2,
    generatedClientFileCount: 0,
    artifacts: [
      (type: 'runtimeSource', path: '.spry/src/app.dart'),
      (type: 'openapiArtifact', path: 'public/openapi.json'),
    ],
  );

  test('first failed attempt has no successful generation', () {
    final state = McpBuildState();
    expect((state.toJson()['latest_attempt'] as Map)['status'], 'unknown');
    final first = state.begin();
    expect(state.toJson()['last_successful_generation'], isNull);
    expect((state.toJson()['latest_attempt'] as Map)['status'], 'building');
    state.fail(first);
    expect(state.toJson()['latest_attempt'], {
      'generation': 1,
      'status': 'failed',
    });
    expect(state.toJson()['last_successful_generation'], isNull);
  });

  test('success, building, failure and recovery preserve separate history', () {
    final state = McpBuildState();
    succeed(state, state.begin());
    final successful = state.toJson()['last_successful_generation'];
    expect((successful as Map)['generated_openapi_file_count'], 1);
    final failed = state.begin();
    expect(state.toJson()['latest_attempt'], {
      'generation': 2,
      'status': 'building',
    });
    expect(state.toJson()['last_successful_generation'], successful);
    state.fail(failed);
    expect(state.toJson()['latest_attempt'], {
      'generation': 2,
      'status': 'failed',
    });
    expect(state.toJson()['last_successful_generation'], successful);
    expect(state.toJson()['disk_state'], 'unknown');
    succeed(state, state.begin());
    expect(
      (state.toJson()['last_successful_generation'] as Map)['generation'],
      3,
    );
  });

  test(
    'out-of-order async and duplicate completions cannot overwrite latest',
    () async {
      final state = McpBuildState();
      final old = state.begin();
      final oldDone = Completer<void>();
      final completingOld = oldDone.future.then((_) => succeed(state, old));
      final newer = state.begin();
      final newDone = Completer<void>();
      final completingNew = newDone.future.then((_) => succeed(state, newer));
      newDone.complete();
      await completingNew;
      final expected = state.toJson();
      oldDone.complete();
      await completingOld;
      state.fail(old);
      state.fail(newer);
      succeed(state, newer);
      expect(state.toJson(), expected);
      final failing = state.begin();
      state.fail(failing);
      succeed(state, failing);
      expect((state.toJson()['latest_attempt'] as Map)['status'], 'failed');
      expect(
        (state.toJson()['last_successful_generation'] as Map)['generation'],
        newer,
      );
    },
  );

  test('snapshots do not retain mutable input or expose mutable history', () {
    final artifacts = [(type: 'runtimeSource', path: '.spry/src/app.dart')];
    final state = McpBuildState();
    state.succeed(
      state.begin(),
      target: 'vm',
      outputDir: '.spry',
      generatedFileCount: 1,
      generatedClientFileCount: 0,
      artifacts: artifacts,
    );
    artifacts.clear();
    final success = state.toJson()['last_successful_generation'] as Map;
    final recorded = success['artifacts'] as List;
    expect(recorded, hasLength(1));
    expect(() => success.clear(), throwsUnsupportedError);
    expect(() => recorded.clear(), throwsUnsupportedError);
    expect(() => (recorded.single as Map).clear(), throwsUnsupportedError);
  });
}
