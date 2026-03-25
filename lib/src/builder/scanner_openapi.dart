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
    switch (contracts.openApiNameFor(typeElement)) {
      case 'OpenAPIRef':
        return _evaluateOpenApiRefObject(unit, expression, activeVariables);
      case 'OpenAPIResponse':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIResponse',
        );
      case 'OpenAPIMediaType':
        return _evaluateOpenApiMediaTypeObject(
          unit,
          expression,
          activeVariables,
        );
      case 'OpenAPISchema':
        return _evaluateOpenApiSchemaObject(unit, expression, activeVariables);
      case 'OpenAPIParameter':
        return _evaluateOpenApiParameterObject(
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

  Future<Object?> _evaluateOpenApiRefObject(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final constructor = expression.constructorName.name?.name;
    final arguments = expression.argumentList.arguments;
    switch (constructor) {
      case 'inline':
        if (arguments.length != 1) {
          throw RouteScanException(
            'OpenAPIRef.inline(...) in `${unit.path}` requires exactly one argument.',
          );
        }
        return evaluateValueExpression(unit, arguments.single, activeVariables);
      case 'ref':
        if (arguments.isEmpty) {
          throw RouteScanException(
            'OpenAPIRef.ref(...) in `${unit.path}` requires a `\$ref` argument.',
          );
        }
        final ref = await evaluateValueExpression(
          unit,
          arguments.first,
          activeVariables,
        );
        if (ref is! String) {
          throw RouteScanException(
            'OpenAPIRef.ref(...) in `${unit.path}` requires a string `\$ref` argument.',
          );
        }
        final result = <String, dynamic>{r'$ref': ref};
        for (final argument in arguments.skip(1)) {
          if (argument is! NamedExpression) {
            throw RouteScanException(
              'OpenAPIRef.ref(...) in `${unit.path}` only supports named trailing arguments.',
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
    throw RouteScanException(
      'Unsupported OpenAPIRef constructor `${expression.toSource()}` in `${unit.path}`.',
    );
  }

  Future<Map<String, dynamic>> _evaluateOpenApiMediaTypeObject(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final result = await _evaluateNamedMapObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPIMediaType',
    );
    if (result['example'] != null && result['examples'] != null) {
      throw RouteScanException(
        'OpenAPIMediaType.example and OpenAPIMediaType.examples are mutually exclusive in `${unit.path}`.',
      );
    }
    return result;
  }

  Future<Object?> _evaluateOpenApiSchemaObject(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final constructor = expression.constructorName.name?.name;
    switch (constructor) {
      case 'anything':
        return true;
      case 'nothing':
        return false;
      case 'ref':
        final ref = await _requirePositionalStringArgument(
          unit,
          expression,
          activeVariables,
          index: 0,
          label: r'$ref',
        );
        return {r'$ref': ref};
      case 'nullable':
        final schema = await _requirePositionalArgument(
          unit,
          expression,
          activeVariables,
          index: 0,
          label: 'schema',
        );
        return _makeSchemaNullable(schema);
      case 'additional':
        final additional = await _requirePositionalArgument(
          unit,
          expression,
          activeVariables,
          index: 0,
          label: 'additional',
        );
        if (additional is! Map<String, dynamic>) {
          throw RouteScanException(
            'OpenAPISchema.additional(...) in `${unit.path}` requires a map argument.',
          );
        }
        return additional;
      case 'string':
      case 'integer':
      case 'number':
      case 'boolean':
      case 'null_':
        final type = switch (constructor) {
          'null_' => 'null',
          _ => constructor!,
        };
        final result = await _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPISchema.$constructor',
          additionalArgumentName: 'additional',
        );
        result['type'] = type;
        return result;
      case 'object':
        final properties = await _requirePositionalArgument(
          unit,
          expression,
          activeVariables,
          index: 0,
          label: 'properties',
        );
        if (properties is! Map<String, dynamic>) {
          throw RouteScanException(
            'OpenAPISchema.object(...) in `${unit.path}` requires a string-keyed map of properties.',
          );
        }
        final result = await _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPISchema.object',
          additionalArgumentName: 'additional',
        );
        result['type'] = 'object';
        result['properties'] = properties;
        return result;
      case 'array':
        final items = await _requirePositionalArgument(
          unit,
          expression,
          activeVariables,
          index: 0,
          label: 'items',
        );
        final result = await _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPISchema.array',
          additionalArgumentName: 'additional',
        );
        result['type'] = 'array';
        result['items'] = items;
        return result;
      case 'oneOf':
      case 'anyOf':
      case 'allOf':
        final schemas = await _requirePositionalArgument(
          unit,
          expression,
          activeVariables,
          index: 0,
          label: 'schemas',
        );
        if (schemas is! List<Object?>) {
          throw RouteScanException(
            'OpenAPISchema.$constructor(...) in `${unit.path}` requires a list of schemas.',
          );
        }
        final result = await _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPISchema.$constructor',
          additionalArgumentName: 'additional',
        );
        result[constructor!] = schemas;
        return result;
    }
    throw RouteScanException(
      'Unsupported OpenAPISchema constructor `${expression.toSource()}` in `${unit.path}`.',
    );
  }

  Future<Map<String, dynamic>> _evaluateOpenApiParameterObject(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables,
  ) async {
    final constructor = expression.constructorName.name?.name;
    final name = await _requirePositionalStringArgument(
      unit,
      expression,
      activeVariables,
      index: 0,
      label: 'name',
    );
    final result = await _evaluateNamedMapObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPIParameter.$constructor',
    );
    final schema = result['schema'];
    final content = result['content'];
    if ((schema == null) == (content == null)) {
      throw RouteScanException(
        'OpenAPIParameter.$constructor(...) in `${unit.path}` requires exactly one of `schema` or `content`.',
      );
    }
    if (content case final Map<String, dynamic> map when map.length != 1) {
      throw RouteScanException(
        'OpenAPIParameter.$constructor(...).content in `${unit.path}` must contain exactly one media type entry.',
      );
    }
    result['name'] = name;
    switch (constructor) {
      case 'path':
        result['in'] = 'path';
        result['required'] = true;
      case 'query':
        result['in'] = 'query';
        if (result['required'] != true) {
          result.remove('required');
        }
      case 'header':
        result['in'] = 'header';
      case 'cookie':
        result['in'] = 'cookie';
      default:
        throw RouteScanException(
          'Unsupported OpenAPIParameter constructor `${expression.toSource()}` in `${unit.path}`.',
        );
    }
    return result;
  }

  Future<Map<String, dynamic>> _evaluateNamedMapObject(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables, {
    required String scope,
    String? additionalArgumentName,
  }) async {
    final result = <String, dynamic>{};
    for (final argument in expression.argumentList.arguments) {
      if (argument is! NamedExpression) {
        continue;
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
            '$scope.extensions in `${unit.path}` must be a map.',
          );
        }
        for (final entry in value.entries) {
          result['x-${entry.key}'] = entry.value;
        }
        continue;
      }
      if (name == additionalArgumentName) {
        if (value is! Map) {
          throw RouteScanException(
            '$scope.$name in `${unit.path}` must be a map.',
          );
        }
        for (final entry in value.entries) {
          result[entry.key as String] = entry.value;
        }
        continue;
      }
      if (value != null) {
        result[name] = value;
      }
    }
    return result;
  }

  Future<Object?> _requirePositionalArgument(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables, {
    required int index,
    required String label,
  }) async {
    final positional = expression.argumentList.arguments
        .whereType<Expression>()
        .where((argument) => argument is! NamedExpression)
        .toList();
    if (index >= positional.length) {
      throw RouteScanException(
        '`${expression.toSource()}` in `${unit.path}` requires a positional `$label` argument.',
      );
    }
    return evaluateValueExpression(unit, positional[index], activeVariables);
  }

  Future<String> _requirePositionalStringArgument(
    ResolvedUnitResult unit,
    InstanceCreationExpression expression,
    Set<String> activeVariables, {
    required int index,
    required String label,
  }) async {
    final value = await _requirePositionalArgument(
      unit,
      expression,
      activeVariables,
      index: index,
      label: label,
    );
    if (value is! String) {
      throw RouteScanException(
        '`${expression.toSource()}` in `${unit.path}` requires a string `$label` argument.',
      );
    }
    return value;
  }

  Object? _makeSchemaNullable(Object? schema) {
    if (schema case final bool value) {
      return value ? true : {'type': 'null'};
    }
    if (schema is! Map<String, dynamic>) {
      return {
        'type': ['null'],
      };
    }
    final type = schema['type'];
    final nullableType = switch (type) {
      final List<Object?> values =>
        values.contains('null') ? values : [...values, 'null'],
      final String value => [value, 'null'],
      null => ['null'],
      _ => ['null'],
    };
    return {...schema, 'type': nullableType};
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
