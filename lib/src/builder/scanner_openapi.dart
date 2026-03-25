// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import 'scanner_exception.dart';
import 'scanner_semantics.dart';

Future<Map<String, dynamic>?> scanRouteOpenApiMetadata(
  ResolvedScannerContext context,
  String filePath,
) async {
  final unit = await context.resolvedUnit(filePath);
  final binding = findTopLevelBinding(unit, 'openapi');
  if (binding == null) {
    return null;
  }
  if (binding.element is! TopLevelVariableElement) {
    throw RouteScanException(
      'Top-level `openapi` in `$filePath` must be declared as a top-level variable.',
    );
  }

  final expression = await _initializerForElement(context, binding.element);
  if (expression == null) {
    throw RouteScanException(
      'Top-level `openapi` in `$filePath` must have an initializer.',
    );
  }

  final evaluator = _ResolvedOpenApiEvaluator(context);
  return evaluator.evaluateRouteExpression(unit, expression, <String>{});
}

final class _ResolvedOpenApiEvaluator {
  _ResolvedOpenApiEvaluator(this._context);

  final ResolvedScannerContext _context;

  Future<Map<String, dynamic>> evaluateRouteExpression(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    return switch (expression) {
      InstanceCreationExpression() => await _evaluateRouteConstructor(
        unit,
        expression,
        activeVariables,
      ),
      SimpleIdentifier() => await _evaluateReferencedRouteValue(
        unit,
        expression.element,
        activeVariables,
      ),
      PrefixedIdentifier() => await _evaluateReferencedRouteValue(
        unit,
        expression.element,
        activeVariables,
      ),
      _ => throw RouteScanException(
        'Top-level `openapi` in `${unit.path}` must use Spry OpenAPI(...) or reference another top-level Spry OpenAPI value. Got `${expression.toSource()}`.',
      ),
    };
  }

  Future<Object?> evaluateValueExpression(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    return switch (expression) {
      NullLiteral() => null,
      BooleanLiteral() => expression.value,
      IntegerLiteral() => expression.value,
      DoubleLiteral() => expression.value,
      SimpleStringLiteral() => expression.value,
      AdjacentStrings() => await _evaluateAdjacentStrings(
        unit,
        expression,
        activeVariables,
      ),
      ListLiteral() => await _evaluateListLiteral(
        unit,
        expression,
        activeVariables,
      ),
      SetOrMapLiteral() => await _evaluateMapLiteral(
        unit,
        expression,
        activeVariables,
      ),
      InstanceCreationExpression() => await _evaluateValueConstructor(
        unit,
        expression,
        activeVariables,
      ),
      SimpleIdentifier() => await _evaluateReferencedValue(
        unit,
        expression.element,
        activeVariables,
      ),
      PrefixedIdentifier() => await _evaluateReferencedValue(
        unit,
        expression.element,
        activeVariables,
      ),
      _ => throw RouteScanException(
        'Unsupported OpenAPI value `${expression.toSource()}` in `${unit.path}`.',
      ),
    };
  }

  Future<Map<String, dynamic>> _evaluateRouteConstructor(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final contracts = await _context.contractsFor(unit);
    final typeElement = expression.constructorName.type.element;
    if (typeElement != contracts.openApiElement) {
      throw RouteScanException(
        'Top-level `openapi` in `${unit.path}` must resolve to Spry `OpenAPI`; '
        'got ${describeElement(typeElement)}.',
      );
    }
    return _evaluateOpenApiObject(unit, expression, activeVariables);
  }

  Future<Object?> _evaluateValueConstructor(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final contracts = await _context.contractsFor(unit);
    final typeElement = expression.constructorName.type.element;
    if (typeElement == contracts.openApiElement) {
      return _evaluateOpenApiObject(unit, expression, activeVariables);
    }
    if (typeElement == contracts.openApiComponentsElement) {
      return _evaluateOpenApiComponentsObject(
        unit,
        expression,
        activeVariables,
      );
    }
    throw RouteScanException(
      'Unsupported OpenAPI constructor `${expression.toSource()}` in `${unit.path}`; '
      'expected a Spry OpenAPI type, got ${describeElement(typeElement)}.',
    );
  }

  Future<Map<String, dynamic>> _evaluateOpenApiObject(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final result = <String, dynamic>{};
    for (final argument in expression.argumentList.arguments) {
      if (argument is! NamedExpression) {
        throw RouteScanException(
          'OpenAPI(...) in `${unit.path}` only supports named arguments.',
        );
      }
      final name = argument.name.label.name;
      final value = await evaluateValueExpression(
        unit,
        argument.expression,
        activeVariables,
      );
      if (name == 'extensions') {
        if (value is! Map) {
          throw RouteScanException(
            'OpenAPI.extensions in `${unit.path}` must be a map.',
          );
        }
        for (final entry in value.entries) {
          result['x-${entry.key}'] = entry.value;
        }
        continue;
      }
      if (name == 'globalComponents') {
        if (value != null) {
          result['x-spry-openapi-global-components'] = value;
        }
        continue;
      }
      if (value != null) {
        result[name] = value;
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> _evaluateOpenApiComponentsObject(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final result = <String, dynamic>{};
    for (final argument in expression.argumentList.arguments) {
      if (argument is! NamedExpression) {
        throw RouteScanException(
          'OpenAPIComponents(...) in `${unit.path}` only supports named arguments.',
        );
      }
      final value = await evaluateValueExpression(
        unit,
        argument.expression,
        activeVariables,
      );
      if (value != null) {
        result[argument.name.label.name] = value;
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> _evaluateReferencedRouteValue(
    ResolvedUnitResult fromUnit,
    Element? element,
    Set<String> activeVariables,
  ) async {
    final normalized = normalizeReferencedElement(element);
    if (normalized is! TopLevelVariableElement) {
      throw RouteScanException(
        'Top-level `openapi` in `${fromUnit.path}` must reference another top-level Spry OpenAPI value; got ${describeElement(normalized)}.',
      );
    }
    final key = '${normalized.library.uri}::${normalized.displayName}';
    if (!activeVariables.add(key)) {
      throw RouteScanException(
        'Circular OpenAPI variable reference detected at `$key`.',
      );
    }
    try {
      final declarationUnit = await _declarationUnitForElement(normalized);
      final expression = await _initializerForElement(_context, normalized);
      if (expression == null) {
        throw RouteScanException(
          'Referenced OpenAPI variable `${normalized.displayName}` in `${declarationUnit.path}` must have an initializer.',
        );
      }
      return evaluateRouteExpression(
        declarationUnit,
        expression,
        activeVariables,
      );
    } finally {
      activeVariables.remove(key);
    }
  }

  Future<Object?> _evaluateReferencedValue(
    ResolvedUnitResult fromUnit,
    Element? element,
    Set<String> activeVariables,
  ) async {
    final normalized = normalizeReferencedElement(element);
    if (normalized is! TopLevelVariableElement) {
      throw RouteScanException(
        'OpenAPI value in `${fromUnit.path}` must reference a top-level variable; got ${describeElement(normalized)}.',
      );
    }
    final key = '${normalized.library.uri}::${normalized.displayName}';
    if (!activeVariables.add(key)) {
      throw RouteScanException(
        'Circular OpenAPI variable reference detected at `$key`.',
      );
    }
    try {
      final declarationUnit = await _declarationUnitForElement(normalized);
      final expression = await _initializerForElement(_context, normalized);
      if (expression == null) {
        throw RouteScanException(
          'Referenced OpenAPI variable `${normalized.displayName}` in `${declarationUnit.path}` must have an initializer.',
        );
      }
      return evaluateValueExpression(
        declarationUnit,
        expression,
        activeVariables,
      );
    } finally {
      activeVariables.remove(key);
    }
  }

  Future<ResolvedUnitResult> _declarationUnitForElement(
    TopLevelVariableElement element,
  ) async {
    final library = element.library;
    final resolvedLibrary = await _context.resolvedLibrary(library);
    final declaration = resolvedLibrary.getFragmentDeclaration(
      element.firstFragment,
    );
    final unit = declaration?.resolvedUnit;
    if (unit == null) {
      throw RouteScanException(
        'Unable to locate resolved declaration for `${element.displayName}` from `${library.uri}`.',
      );
    }
    return unit;
  }

  Future<String> _evaluateAdjacentStrings(
    ResolvedUnitResult unit,
    AdjacentStrings expression,
    Set<String> activeVariables,
  ) async {
    final parts = <String>[];
    for (final part in expression.strings) {
      final value = await evaluateValueExpression(unit, part, activeVariables);
      if (value is! String) {
        throw RouteScanException(
          'OpenAPI adjacent strings in `${unit.path}` only support string parts.',
        );
      }
      parts.add(value);
    }
    return parts.join();
  }

  Future<List<Object?>> _evaluateListLiteral(
    ResolvedUnitResult unit,
    ListLiteral expression,
    Set<String> activeVariables,
  ) async {
    final result = <Object?>[];
    for (final element in expression.elements) {
      if (element is! Expression) {
        throw RouteScanException(
          'OpenAPI list values in `${unit.path}` only support expression elements.',
        );
      }
      result.add(await evaluateValueExpression(unit, element, activeVariables));
    }
    return result;
  }

  Future<Map<String, dynamic>> _evaluateMapLiteral(
    ResolvedUnitResult unit,
    SetOrMapLiteral expression,
    Set<String> activeVariables,
  ) async {
    final result = <String, dynamic>{};
    for (final element in expression.elements) {
      if (element is! MapLiteralEntry) {
        throw RouteScanException(
          'OpenAPI map values in `${unit.path}` only support map literal entries.',
        );
      }
      result[_readStringMapKey(unit, element.key)] =
          await evaluateValueExpression(unit, element.value, activeVariables);
    }
    return result;
  }

  String _readStringMapKey(ResolvedUnitResult unit, Expression expression) {
    return switch (expression) {
      SimpleStringLiteral() => expression.value,
      AdjacentStrings() =>
        expression.strings
            .map(
              (part) => switch (part) {
                SimpleStringLiteral() => part.value,
                _ => throw RouteScanException(
                  'OpenAPI map keys in `${unit.path}` only support string literals.',
                ),
              },
            )
            .join(),
      _ => throw RouteScanException(
        'OpenAPI map keys in `${unit.path}` only support string literals.',
      ),
    };
  }
}

Future<Expression?> _initializerForElement(
  ResolvedScannerContext context,
  Element element,
) async {
  final normalized = normalizeReferencedElement(element);
  if (normalized is! TopLevelVariableElement) {
    return null;
  }
  final library = normalized.library;
  final resolvedLibrary = await context.resolvedLibrary(library);
  final declaration = resolvedLibrary.getFragmentDeclaration(
    normalized.firstFragment,
  );
  final node = declaration?.node;
  if (node is VariableDeclaration) {
    return node.initializer;
  }
  return null;
}
