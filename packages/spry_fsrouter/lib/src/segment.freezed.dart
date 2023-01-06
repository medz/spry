// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'segment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Segment {
  String get directory => throw _privateConstructorUsedError;
  String? get handler => throw _privateConstructorUsedError;
  String? get middleware => throw _privateConstructorUsedError;
  Map<String, Segment> get methodSegments => throw _privateConstructorUsedError;
  Map<String, String> get paramsMiddleware =>
      throw _privateConstructorUsedError;
  SegmentConfiguration? get configuration => throw _privateConstructorUsedError;
  Iterable<Segment> get children => throw _privateConstructorUsedError;
}

/// @nodoc

class _$_Segment implements _Segment {
  const _$_Segment(
      {required this.directory,
      this.handler,
      this.middleware,
      required final Map<String, Segment> methodSegments,
      required final Map<String, String> paramsMiddleware,
      this.configuration,
      required this.children})
      : _methodSegments = methodSegments,
        _paramsMiddleware = paramsMiddleware;

  @override
  final String directory;
  @override
  final String? handler;
  @override
  final String? middleware;
  final Map<String, Segment> _methodSegments;
  @override
  Map<String, Segment> get methodSegments {
    if (_methodSegments is EqualUnmodifiableMapView) return _methodSegments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_methodSegments);
  }

  final Map<String, String> _paramsMiddleware;
  @override
  Map<String, String> get paramsMiddleware {
    if (_paramsMiddleware is EqualUnmodifiableMapView) return _paramsMiddleware;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_paramsMiddleware);
  }

  @override
  final SegmentConfiguration? configuration;
  @override
  final Iterable<Segment> children;

  @override
  String toString() {
    return 'Segment(directory: $directory, handler: $handler, middleware: $middleware, methodSegments: $methodSegments, paramsMiddleware: $paramsMiddleware, configuration: $configuration, children: $children)';
  }
}

abstract class _Segment implements Segment {
  const factory _Segment(
      {required final String directory,
      final String? handler,
      final String? middleware,
      required final Map<String, Segment> methodSegments,
      required final Map<String, String> paramsMiddleware,
      final SegmentConfiguration? configuration,
      required final Iterable<Segment> children}) = _$_Segment;

  @override
  String get directory;
  @override
  String? get handler;
  @override
  String? get middleware;
  @override
  Map<String, Segment> get methodSegments;
  @override
  Map<String, String> get paramsMiddleware;
  @override
  SegmentConfiguration? get configuration;
  @override
  Iterable<Segment> get children;
}
