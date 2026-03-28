import '../middleware.dart';

/// Creates middleware that records downstream request handling time.
Middleware timing({String metricName = 'app', int fractionDigits = 1}) {
  RangeError.checkNotNegative(fractionDigits, 'fractionDigits');

  return (event, next) async {
    final stopwatch = Stopwatch()..start();
    final response = await next();
    stopwatch.stop();

    response.headers.append(
      'server-timing',
      _formatServerTimingMetric(
        metricName,
        stopwatch.elapsedMicroseconds,
        fractionDigits,
      ),
    );

    return response;
  };
}

String _formatServerTimingMetric(
  String metricName,
  int elapsedMicroseconds,
  int fractionDigits,
) {
  final elapsedMilliseconds =
      elapsedMicroseconds / Duration.microsecondsPerMillisecond;
  return '$metricName;dur=${elapsedMilliseconds.toStringAsFixed(fractionDigits)}';
}
