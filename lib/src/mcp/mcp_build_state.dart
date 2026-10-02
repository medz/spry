/// Metadata for build attempts in one `spry serve` process.
///
/// A successful generation is historical evidence of completed writes, not a
/// guarantee that those files still exist or match the running application.
final class McpBuildState {
  int _generation = 0;
  String _status = 'unknown';
  Map<String, Object?>? _lastSuccess;

  /// Starts an attempt and returns its monotonically increasing generation.
  int begin() {
    _status = 'building';
    return ++_generation;
  }

  /// Records only the latest pending attempt; stale or duplicate completions
  /// cannot replace a newer attempt or its successful snapshot.
  void succeed(
    int generation, {
    required String target,
    required String outputDir,
    required int generatedFileCount,
    required int generatedClientFileCount,
    required List<({String type, String path})> artifacts,
  }) {
    if (generation != _generation || _status != 'building') return;
    _status = 'succeeded';
    _lastSuccess = Map.unmodifiable({
      'generation': generation,
      'target': target,
      'output_dir': outputDir,
      'generated_file_count': generatedFileCount,
      'generated_client_file_count': generatedClientFileCount,
      'generated_openapi_file_count': artifacts
          .where((artifact) => artifact.type == 'openapiArtifact')
          .length,
      'artifacts': List.unmodifiable([
        for (final artifact in artifacts)
          Map<String, String>.unmodifiable({
            'type': artifact.type,
            'path': artifact.path,
          }),
      ]),
    });
  }

  /// Failure does not discard the historical successful generation.
  void fail(int generation) {
    if (generation != _generation || _status != 'building') return;
    _status = 'failed';
  }

  /// Serializes metadata without inspecting disk contents or runner readiness.
  Map<String, Object?> toJson() => {
    'source': 'serve',
    'latest_attempt': {
      if (_generation != 0) 'generation': _generation,
      'status': _status,
    },
    'last_successful_generation': _lastSuccess,
    'disk_state': 'unknown',
  };
}

/// Inspection-only MCP cannot infer a serve session from files on disk.
const unknownBuildState = {
  'source': 'inspection',
  'latest_attempt': {'status': 'unknown'},
  'last_successful_generation': null,
  'disk_state': 'unknown',
};
