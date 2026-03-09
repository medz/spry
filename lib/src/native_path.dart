const _relativeRootMarker = '__spry_relative_root__';

/// Resolves [childPath] within [rootPath] for runtimes that expose native paths.
String? resolveNativeChildPath(String rootPath, String childPath) {
  final normalizedRoot = _normalizeNativePath(rootPath, anchorRelative: true);
  final normalizedTarget = _normalizeNativePath(
    '$rootPath/$childPath',
    anchorRelative: true,
  );
  if (!_isWithinNativePath(normalizedRoot, normalizedTarget)) {
    return null;
  }
  return _stripRelativeAnchor(normalizedTarget);
}

String _normalizeNativePath(String path, {required bool anchorRelative}) {
  var normalized = path.replaceAll('\\', '/');
  if (anchorRelative && !_hasNativeRoot(normalized)) {
    if (normalized == '.' || normalized.isEmpty) {
      normalized = '/$_relativeRootMarker';
    } else {
      normalized = '/$_relativeRootMarker/$normalized';
    }
  }

  final parts = <String>[];
  var prefix = '';

  if (normalized.startsWith('//')) {
    prefix = '//';
  } else if (normalized.length >= 2 && normalized[1] == ':') {
    prefix = normalized.substring(0, 2);
  } else if (normalized.startsWith('/')) {
    prefix = '/';
  }

  final startIndex = prefix == '//'
      ? 2
      : (prefix.isNotEmpty ? prefix.length : 0);
  for (final segment in normalized.substring(startIndex).split('/')) {
    if (segment.isEmpty || segment == '.') {
      continue;
    }
    if (segment == '..') {
      if (parts.isEmpty) {
        parts.add('..');
      } else if (parts.last != '..') {
        parts.removeLast();
      } else {
        parts.add('..');
      }
      continue;
    }
    parts.add(segment);
  }

  final body = parts.join('/');
  if (prefix.isEmpty) {
    return body.isEmpty ? '.' : body;
  }
  if (body.isEmpty) {
    return prefix;
  }
  if (prefix == '/' || prefix == '//') {
    return '$prefix$body';
  }
  return '$prefix/$body';
}

bool _hasNativeRoot(String path) {
  return path.startsWith('/') ||
      path.startsWith('//') ||
      (path.length >= 2 && path[1] == ':');
}

String _stripRelativeAnchor(String path) {
  final anchor = '/$_relativeRootMarker';
  if (path == anchor) {
    return '.';
  }
  if (path.startsWith('$anchor/')) {
    return path.substring(anchor.length + 1);
  }
  return path;
}

bool _isWithinNativePath(String rootPath, String targetPath) {
  if (targetPath == rootPath) {
    return true;
  }

  final normalizedRoot = rootPath.endsWith('/') ? rootPath : '$rootPath/';
  return targetPath.startsWith(normalizedRoot);
}
