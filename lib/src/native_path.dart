import 'package:path/path.dart' as p;

const _relativeRootMarker = '__spry_relative_root__';

/// Resolves [childPath] within [rootPath] for runtimes that expose native paths.
String? resolveNativeChildPath(
  String rootPath,
  String childPath, {
  required p.Style style,
}) {
  final context = _nativeContext(style);
  final root = context.normalize(context.absolute(rootPath));
  final target = context.normalize(context.absolute(rootPath, childPath));
  if (target != root && !context.isWithin(root, target)) {
    return null;
  }
  return _stripRelativeAnchor(target, context: context);
}

p.Context _nativeContext(p.Style style) {
  return p.Context(style: style, current: _anchorRoot(style));
}

String _anchorRoot(p.Style style) {
  if (style == p.Style.windows) {
    return 'C:\\$_relativeRootMarker';
  }
  return '/$_relativeRootMarker';
}

String _stripRelativeAnchor(String path, {required p.Context context}) {
  final anchor = _anchorRoot(context.style);
  if (path == anchor) {
    return '.';
  }

  final prefixed = '$anchor${context.separator}';
  if (path.startsWith(prefixed)) {
    return path.substring(prefixed.length);
  }
  return path;
}
