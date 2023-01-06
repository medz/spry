// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SegmentConfiguration _$$_SegmentConfigurationFromJson(
        Map<String, dynamic> json) =>
    _$_SegmentConfiguration(
      colocation: json['colocation'] as bool?,
      expression: json['expression'] as String?,
    );

Map<String, dynamic> _$$_SegmentConfigurationToJson(
        _$_SegmentConfiguration instance) =>
    <String, dynamic>{
      'colocation': instance.colocation,
      'expression': instance.expression,
    };
