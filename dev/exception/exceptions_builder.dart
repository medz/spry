import 'exception_filter.dart';

abstract interface class ExceptionsBuilder {
  /// Adds a new exception filter to the list of filters.
  void addFilter<T>(ExceptionFilter<T> filter);
}
