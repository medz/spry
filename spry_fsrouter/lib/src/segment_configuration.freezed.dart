// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'segment_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SegmentConfiguration _$SegmentConfigurationFromJson(Map<String, dynamic> json) {
  return _SegmentConfiguration.fromJson(json);
}

/// @nodoc
mixin _$SegmentConfiguration {
  String? get expression => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable()
class _$_SegmentConfiguration implements _SegmentConfiguration {
  const _$_SegmentConfiguration({this.expression});

  factory _$_SegmentConfiguration.fromJson(Map<String, dynamic> json) =>
      _$$_SegmentConfigurationFromJson(json);

  @override
  final String? expression;

  @override
  String toString() {
    return 'SegmentConfiguration(expression: $expression)';
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$_SegmentConfigurationToJson(
      this,
    );
  }
}

abstract class _SegmentConfiguration implements SegmentConfiguration {
  const factory _SegmentConfiguration({final String? expression}) =
      _$_SegmentConfiguration;

  factory _SegmentConfiguration.fromJson(Map<String, dynamic> json) =
      _$_SegmentConfiguration.fromJson;

  @override
  String? get expression;
}
