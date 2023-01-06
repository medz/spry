import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'segment_configuration.g.dart';
part 'segment_configuration.freezed.dart';

/// Path segment configuration.
@freezed
class SegmentConfiguration with _$SegmentConfiguration {
  /// Creates a new path segment configuration.
  const factory SegmentConfiguration({
    String? expression,
  }) = _SegmentConfiguration;

  /// Creates a new path segment configuration from a JSON object.
  factory SegmentConfiguration.fromJson(Map<String, dynamic> json) =>
      _$SegmentConfigurationFromJson(json);

  /// Creates a new path segment configuration from a YAML string.
  factory SegmentConfiguration.fromYaml(String yaml, {Uri? uri}) {
    final YamlMap map = loadYaml(yaml, sourceUrl: uri) as YamlMap;

    // print(map.cast());
    // exit(0);

    return SegmentConfiguration.fromJson(map.cast());
  }
}
