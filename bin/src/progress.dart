import 'dart:async';
import 'dart:io';

import 'package:coal/utils.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';

import 'ansi.dart';
import 'spinner.dart';

final class CliProgressReporter {
  CliProgressReporter._(this._spinner, this._out, this._active);

  factory CliProgressReporter.start(StringSink out, String label) {
    return CliProgressReporter._(
      Spinner.start(out, label),
      out,
      stdout.hasTerminal,
    );
  }

  final Spinner _spinner;
  final StringSink _out;
  final bool _active;

  void update(String message) {
    if (_active) {
      _spinner.update(message);
      return;
    }
    _out.writeln('  $message');
  }

  Future<void> done() async {
    if (_active) {
      stdout.write('${eraseLines(1)}$cursorShow');
      await stdout.flush();
    }
  }

  Future<void> fail(String message) async {
    await _spinner.fail('  ${red('✗')}  $message');
  }
}

final class ScanSummary {
  const ScanSummary({required this.routeCount, required this.middlewareCount});

  final int routeCount;
  final int middlewareCount;
}

final class ObservedScanEntries {
  const ObservedScanEntries({required this.entries, required this.summary});

  final Stream<ScanEntry> entries;
  final Future<ScanSummary> summary;
}

String formatProgressDuration(Duration duration) {
  if (duration.inMilliseconds < 1000) {
    return '${duration.inMilliseconds}ms';
  }
  return '${(duration.inMilliseconds / 1000).toStringAsFixed(1)}s';
}

String displayPath(String path, {required String from}) {
  return p.relative(path, from: from).replaceAll('\\', '/');
}

String describeScanEntry(ScanEntry entry, String rootDir) {
  final file = displayPath(switch (entry.type) {
    ScanEntryType.route || ScanEntryType.fallback => entry.route!.filePath,
    ScanEntryType.globalMiddleware ||
    ScanEntryType.scopedMiddleware => entry.middleware!.filePath,
    ScanEntryType.scopedError => entry.error!.filePath,
    ScanEntryType.hooks => entry.hooks!.filePath,
  }, from: rootDir);
  return switch (entry.type) {
    ScanEntryType.route => 'Scanning route handlers: $file',
    ScanEntryType.globalMiddleware => 'Scanning global middleware: $file',
    ScanEntryType.scopedMiddleware => 'Scanning scoped middleware: $file',
    ScanEntryType.scopedError => 'Scanning scoped errors: $file',
    ScanEntryType.fallback => 'Scanning fallback handler: $file',
    ScanEntryType.hooks => 'Scanning lifecycle hooks: $file',
  };
}

String describeGeneratedEntry(GeneratedEntry entry, {required String rootDir}) {
  final path = entry.rootRelative
      ? displayPath(entry.path, from: rootDir)
      : entry.path;
  return switch (entry.type) {
    GeneratedEntryType.runtimeSource => 'Building runtime source: $path',
    GeneratedEntryType.openapiArtifact => 'Building OpenAPI schema to $path',
    GeneratedEntryType.clientSource => 'Building client source: $path',
    GeneratedEntryType.targetArtifact => 'Building target artifact: $path',
    GeneratedEntryType.staticCopy => 'Syncing static asset: $path',
  };
}

ObservedScanEntries observeScanEntries(
  Stream<ScanEntry> source, {
  CliProgressReporter? reporter,
  String? rootDir,
}) {
  final controller = StreamController<ScanEntry>();
  final summary = Completer<ScanSummary>();
  unawaited(() async {
    var routeCount = 0;
    var middlewareCount = 0;
    try {
      await for (final entry in source) {
        if (reporter != null && rootDir != null) {
          reporter.update(describeScanEntry(entry, rootDir));
        }
        switch (entry.type) {
          case ScanEntryType.route || ScanEntryType.fallback:
            routeCount++;
          case ScanEntryType.globalMiddleware || ScanEntryType.scopedMiddleware:
            middlewareCount++;
          case ScanEntryType.scopedError || ScanEntryType.hooks:
            break;
        }
        controller.add(entry);
      }
      summary.complete(
        ScanSummary(routeCount: routeCount, middlewareCount: middlewareCount),
      );
    } catch (error, stackTrace) {
      if (!summary.isCompleted) {
        summary.completeError(error, stackTrace);
      }
      controller.addError(error, stackTrace);
    } finally {
      await controller.close();
    }
  }());

  return ObservedScanEntries(
    entries: controller.stream,
    summary: summary.future,
  );
}

Stream<GeneratedEntry> reportGeneratedEntries(
  Stream<GeneratedEntry> entries,
  CliProgressReporter reporter, {
  required String rootDir,
}) async* {
  await for (final entry in entries) {
    reporter.update(describeGeneratedEntry(entry, rootDir: rootDir));
    yield entry;
  }
}
