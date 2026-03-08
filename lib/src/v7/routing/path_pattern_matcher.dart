final class PathPatternMatch {
  const PathPatternMatch(this.params);

  final Map<String, String> params;
}

PathPatternMatch? matchPathPattern(String pattern, String path) {
  final normalizedPattern = _normalize(pattern);
  final normalizedPath = _normalize(path);

  if (normalizedPattern == '/*') {
    return PathPatternMatch(<String, String>{
      'wildcard': normalizedPath == '/' ? '' : normalizedPath.substring(1),
    });
  }

  final patternSegments = _segments(normalizedPattern);
  final pathSegments = _segments(normalizedPath);
  final params = <String, String>{};

  for (var index = 0; index < patternSegments.length; index++) {
    final patternSegment = patternSegments[index];

    if (patternSegment == '*') {
      params['wildcard'] = pathSegments.length <= index
          ? ''
          : pathSegments.skip(index).join('/');
      return PathPatternMatch(Map.unmodifiable(params));
    }

    if (index >= pathSegments.length) {
      return null;
    }

    final pathSegment = pathSegments[index];
    if (patternSegment.startsWith(':')) {
      params[patternSegment.substring(1)] = pathSegment;
      continue;
    }

    if (patternSegment != pathSegment) {
      return null;
    }
  }

  if (patternSegments.length != pathSegments.length) {
    return null;
  }

  return PathPatternMatch(Map.unmodifiable(params));
}

String _normalize(String value) {
  if (value.isEmpty) {
    return '/';
  }
  if (value.length > 1 && value.endsWith('/')) {
    return value.substring(0, value.length - 1);
  }
  return value;
}

List<String> _segments(String value) {
  return value.split('/').where((segment) => segment.isNotEmpty).toList();
}
