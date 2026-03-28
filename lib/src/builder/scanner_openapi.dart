// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import 'scanner_exception.dart';
import 'scanner_semantics.dart';

Future<Map<String, Object?>?> scanRouteOpenApiMetadata(
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

  final evaluator = _ResolvedOpenApiEvaluator(context);
  final expression = await evaluator._initializerForElement(binding.element);
  if (expression == null) {
    throw RouteScanException(
      'Top-level `openapi` in `$filePath` must have an initializer.',
    );
  }

  return evaluator.evaluateRouteExpression(unit, expression, <String>{});
}

final class _ResolvedOpenApiEvaluator {
  _ResolvedOpenApiEvaluator(this._context);

  final ResolvedScannerContext _context;

  Future<Map<String, Object?>> evaluateRouteExpression(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    return switch (expression) {
      InstanceCreationExpression() => await _evaluateRouteInvocation(
        unit,
        expression,
        activeVariables,
      ),
      DotShorthandConstructorInvocation() => await _evaluateRouteInvocation(
        unit,
        expression,
        activeVariables,
      ),
      DotShorthandInvocation() => await _evaluateRouteInvocation(
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
      InstanceCreationExpression() => await _evaluateValueInvocation(
        unit,
        expression,
        activeVariables,
      ),
      DotShorthandConstructorInvocation() => await _evaluateValueInvocation(
        unit,
        expression,
        activeVariables,
      ),
      DotShorthandInvocation() => await _evaluateValueInvocation(
        unit,
        expression,
        activeVariables,
      ),
      DotShorthandPropertyAccess() => await _evaluateReferencedValue(
        unit,
        expression.propertyName.element,
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

  Future<Map<String, Object?>> _evaluateRouteInvocation(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final contracts = await _context.contractsFor(unit);
    final typeElement = _invocationTypeElement(expression);
    if (typeElement != contracts.openApiElement) {
      throw RouteScanException(
        'Top-level `openapi` in `${unit.path}` must resolve to Spry `OpenAPI`; '
        'got ${describeElement(typeElement)}.',
      );
    }
    return _evaluateOpenApiObject(unit, expression, activeVariables);
  }

  Future<Object?> _evaluateValueInvocation(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final contracts = await _context.contractsFor(unit);
    final typeElement = _invocationTypeElement(expression);
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
      case 'OpenAPIOperation':
        return _evaluateOpenApiOperationObject(
          unit,
          expression,
          activeVariables,
        );
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
      case 'OpenAPIEncoding':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIEncoding',
        );
      case 'OpenAPISchema':
        return _evaluateOpenApiSchemaObject(unit, expression, activeVariables);
      case 'OpenAPIParameter':
        return _evaluateOpenApiParameterObject(
          unit,
          expression,
          activeVariables,
        );
      case 'OpenAPIHeader':
        return _evaluateOpenApiHeaderObject(unit, expression, activeVariables);
      case 'OpenAPIRequestBody':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIRequestBody',
        );
      case 'OpenAPIExample':
        return _evaluateOpenApiExampleObject(unit, expression, activeVariables);
      case 'OpenAPILink':
        return _evaluateOpenApiLinkObject(unit, expression, activeVariables);
      case 'OpenAPISecurityRequirement':
        return _evaluateOpenApiSecurityRequirementObject(
          unit,
          expression,
          activeVariables,
        );
      case 'OpenAPISecurityScheme':
        return _evaluateOpenApiSecuritySchemeObject(
          unit,
          expression,
          activeVariables,
        );
      case 'OpenAPIOAuthFlow':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIOAuthFlow',
        );
      case 'OpenAPIOAuthFlows':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIOAuthFlows',
        );
      case 'OpenAPIServer':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIServer',
        );
      case 'OpenAPIServerVariable':
        return _evaluateOpenApiServerVariableObject(
          unit,
          expression,
          activeVariables,
        );
      case 'OpenAPIExternalDocs':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIExternalDocs',
        );
      case 'OpenAPITag':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPITag',
        );
      case 'OpenAPIPathItem':
        return _evaluateNamedMapObject(
          unit,
          expression,
          activeVariables,
          scope: 'OpenAPIPathItem',
        );
    }
    throw RouteScanException(
      'Unsupported OpenAPI constructor `${expression.toSource()}` in `${unit.path}`; '
      'expected a Spry OpenAPI type, got ${describeElement(typeElement)}.',
    );
  }

  String? _invocationConstructorName(Expression expression) {
    return switch (expression) {
      InstanceCreationExpression() => expression.constructorName.name?.name,
      DotShorthandConstructorInvocation() => expression.constructorName.name,
      DotShorthandInvocation() => expression.memberName.name,
      _ => null,
    };
  }

  ArgumentList _invocationArguments(Expression expression) {
    return switch (expression) {
      InstanceCreationExpression() => expression.argumentList,
      DotShorthandConstructorInvocation() => expression.argumentList,
      DotShorthandInvocation() => expression.argumentList,
      _ => throw RouteScanException(
        'Unsupported OpenAPI invocation `${expression.toSource()}`.',
      ),
    };
  }

  Element? _invocationTypeElement(Expression expression) {
    return _normalizeInvocationTypeElement(switch (expression) {
      InstanceCreationExpression() => expression.constructorName.type.element,
      DotShorthandConstructorInvocation() =>
        expression.element?.enclosingElement,
      DotShorthandInvocation() => switch (expression.memberName.element) {
        final ExecutableElement element => element.enclosingElement,
        _ => null,
      },
      _ => null,
    });
  }

  Element? _normalizeInvocationTypeElement(Element? element) {
    return switch (element) {
      final TypeAliasElement alias => _normalizeInvocationTypeElement(
        alias.aliasedType.element,
      ),
      _ => element,
    };
  }

  Future<Object?> _evaluateOpenApiRefObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final constructor = _invocationConstructorName(expression);
    final arguments = _invocationArguments(expression).arguments;
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

  Future<Map<String, Object?>> _evaluateOpenApiMediaTypeObject(
    ResolvedUnitResult unit,
    Expression expression,
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
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final constructor = _invocationConstructorName(expression);
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
        if (additional is! Map<String, Object?>) {
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
        final type = constructor == 'null_' ? 'null' : constructor!;
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
        if (properties is! Map<String, Object?>) {
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

  Future<Map<String, Object?>> _evaluateOpenApiParameterObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final constructor = _invocationConstructorName(expression);
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
    if (schema == null && content == null) {
      throw RouteScanException(
        'OpenAPIParameter.$constructor(...) in `${unit.path}` requires `schema` or `content`.',
      );
    }
    if (schema != null && content != null) {
      throw RouteScanException(
        'OpenAPIParameter.$constructor(...) in `${unit.path}` cannot have both `schema` and `content`.',
      );
    }
    if (content case final Map<String, Object?> map when map.length != 1) {
      throw RouteScanException(
        'OpenAPIParameter.$constructor(...).content in `${unit.path}` must contain exactly one media type entry.',
      );
    }
    _validateExclusiveFields(
      unit,
      result,
      first: 'example',
      second: 'examples',
      scope: 'OpenAPIParameter.$constructor',
    );
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

  Future<Map<String, Object?>> _evaluateOpenApiHeaderObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final result = await _evaluateNamedMapObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPIHeader',
    );
    _validateSchemaOrContent(unit, result, scope: 'OpenAPIHeader');
    _validateExclusiveFields(
      unit,
      result,
      first: 'example',
      second: 'examples',
      scope: 'OpenAPIHeader',
    );
    return result;
  }

  Future<Map<String, Object?>> _evaluateOpenApiExampleObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final result = await _evaluateNamedMapObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPIExample',
    );
    _validateExclusiveFields(
      unit,
      result,
      first: 'value',
      second: 'externalValue',
      scope: 'OpenAPIExample',
    );
    return result;
  }

  Future<Map<String, Object?>> _evaluateOpenApiLinkObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final result = await _evaluateNamedMapObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPILink',
    );
    _validateExclusiveFields(
      unit,
      result,
      first: 'operationRef',
      second: 'operationId',
      scope: 'OpenAPILink',
    );
    return result;
  }

  Future<Map<String, Object?>> _evaluateOpenApiSecurityRequirementObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final schemes = await _requirePositionalArgument(
      unit,
      expression,
      activeVariables,
      index: 0,
      label: 'schemes',
    );
    if (schemes is! Map<String, Object?>) {
      throw RouteScanException(
        'OpenAPISecurityRequirement(...) in `${unit.path}` requires a string-keyed map.',
      );
    }
    return schemes;
  }

  Future<Map<String, Object?>> _evaluateOpenApiSecuritySchemeObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final constructor = _invocationConstructorName(expression);
    final result = await _evaluateNamedMapObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPISecurityScheme.$constructor',
    );
    switch (constructor) {
      case 'apiKey':
        final location = result.remove('location');
        if (location is! String) {
          throw RouteScanException(
            'OpenAPISecurityScheme.apiKey(...) in `${unit.path}` requires a valid `location` enum value.',
          );
        }
        result['type'] = 'apiKey';
        result['in'] = location;
      case 'http':
        if (result['bearerFormat'] != null && result['scheme'] != 'bearer') {
          throw RouteScanException(
            'OpenAPISecurityScheme.http.bearerFormat in `${unit.path}` is only valid when scheme is `bearer`.',
          );
        }
        result['type'] = 'http';
      case 'oauth2':
        result['type'] = 'oauth2';
      case 'openIdConnect':
        result['type'] = 'openIdConnect';
      case 'mutualTLS':
        result['type'] = 'mutualTLS';
      default:
        throw RouteScanException(
          'Unsupported OpenAPISecurityScheme constructor `${expression.toSource()}` in `${unit.path}`.',
        );
    }
    return result;
  }

  Future<Map<String, Object?>> _evaluateOpenApiServerVariableObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final result = await _evaluateNamedMapObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPIServerVariable',
    );
    if (result['values'] case final value?) {
      if (value is! List) {
        throw RouteScanException(
          'OpenAPIServerVariable.values in `${unit.path}` must be a list.',
        );
      }
      result['enum'] = value;
      result.remove('values');
    }
    if (result['defaultValue'] case final value?) {
      if (value is! String) {
        throw RouteScanException(
          'OpenAPIServerVariable.defaultValue in `${unit.path}` must be a string.',
        );
      }
      result['default'] = value;
      result.remove('defaultValue');
    }
    return result;
  }

  Future<Map<String, Object?>> _evaluateOpenApiOperationObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables, {
    String scope = 'OpenAPIOperation',
  }) async {
    final result = <String, dynamic>{};
    for (final argument in _invocationArguments(expression).arguments) {
      if (argument is! NamedExpression) {
        throw RouteScanException(
          '$scope(...) in `${unit.path}` only supports named arguments.',
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
            '$scope.extensions in `${unit.path}` must be a map.',
          );
        }
        for (final entry in value.entries) {
          result['x-${entry.key}'] = entry.value;
        }
        continue;
      }
      if (value != null) {
        result[name] = value;
      }
    }
    // OAS 3.1.0 requires `responses` to be present on every operation.
    // When the annotation omits it we inject the minimal valid stub
    // `{"default": {"description": ""}}` rather than rejecting the route.
    // Developers can always override this by explicitly providing `responses`.
    result.putIfAbsent(
      'responses',
      () => {
        'default': {'description': ''},
      },
    );
    return result;
  }

  Future<Map<String, Object?>> _evaluateNamedMapObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables, {
    required String scope,
    String? additionalArgumentName,
  }) async {
    final result = <String, dynamic>{};
    for (final argument in _invocationArguments(expression).arguments) {
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
    Expression expression,
    Set<String> activeVariables, {
    required int index,
    required String label,
  }) async {
    final positional = _invocationArguments(
      expression,
    ).arguments.where((argument) => argument is! NamedExpression).toList();
    if (index >= positional.length) {
      throw RouteScanException(
        '`${expression.toSource()}` in `${unit.path}` requires a positional `$label` argument.',
      );
    }
    return evaluateValueExpression(unit, positional[index], activeVariables);
  }

  Future<String> _requirePositionalStringArgument(
    ResolvedUnitResult unit,
    Expression expression,
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
    if (schema is! Map<String, Object?>) {
      return {
        'type': ['null'],
      };
    }
    final type = schema['type'];
    // Schemas without an explicit type (e.g. $ref, oneOf, anyOf, allOf) must
    // not have a sibling `type` array injected — that would produce invalid
    // OpenAPI. Wrap them in `anyOf` to express nullability instead.
    if (type == null) {
      return {
        'anyOf': [
          schema,
          {'type': 'null'},
        ],
      };
    }
    final nullableType = switch (type) {
      final List<Object?> values =>
        values.contains('null') ? values : [...values, 'null'],
      final String value => [value, 'null'],
      _ => [type, 'null'],
    };
    return {...schema, 'type': nullableType};
  }

  Future<Map<String, Object?>> _evaluateOpenApiObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    // Evaluate shared operation fields using the common evaluator, then
    // remap the Dart-side `globalComponents` parameter to its internal key.
    final result = await _evaluateOpenApiOperationObject(
      unit,
      expression,
      activeVariables,
      scope: 'OpenAPI',
    );
    final globalComponents = result.remove('globalComponents');
    if (globalComponents != null) {
      result['x-spry-openapi-global-components'] = globalComponents;
    }
    return result;
  }

  Future<Map<String, Object?>> _evaluateOpenApiComponentsObject(
    ResolvedUnitResult unit,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    final result = <String, dynamic>{};
    for (final argument in _invocationArguments(expression).arguments) {
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

  Future<Map<String, Object?>> _evaluateReferencedRouteValue(
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
    return _resolveTopLevelVariable(
      normalized,
      activeVariables,
      (unit, expr) => evaluateRouteExpression(unit, expr, activeVariables),
    );
  }

  Future<Object?> _evaluateReferencedValue(
    ResolvedUnitResult fromUnit,
    Element? element,
    Set<String> activeVariables,
  ) async {
    final normalized = normalizeReferencedElement(element);
    final contracts = await _context.contractsFor(fromUnit);
    if (normalized is FieldElement &&
        normalized.enclosingElement is EnumElement) {
      final enumElement = normalized.enclosingElement as EnumElement;
      if (contracts.openApiElementNamed(enumElement.displayName) ==
          enumElement) {
        return normalized.displayName;
      }
    }
    if (normalized is! TopLevelVariableElement) {
      throw RouteScanException(
        'OpenAPI value in `${fromUnit.path}` must reference a top-level variable; got ${describeElement(normalized)}.',
      );
    }
    return _resolveTopLevelVariable(
      normalized,
      activeVariables,
      (unit, expr) => evaluateValueExpression(unit, expr, activeVariables),
    );
  }

  /// Guards against circular references and resolves a top-level variable to
  /// a value by evaluating its initializer expression.
  Future<T> _resolveTopLevelVariable<T>(
    TopLevelVariableElement normalized,
    Set<String> activeVariables,
    Future<T> Function(ResolvedUnitResult unit, Expression expression) evaluate,
  ) async {
    final key = '${normalized.library.uri}::${normalized.displayName}';
    if (!activeVariables.add(key)) {
      throw RouteScanException(
        'Circular OpenAPI variable reference detected at `$key`.',
      );
    }
    try {
      final declarationUnit = await _declarationUnitForElement(normalized);
      final expression = await _initializerForElement(normalized);
      if (expression == null) {
        throw RouteScanException(
          'Referenced OpenAPI variable `${normalized.displayName}` in `${declarationUnit.path}` must have an initializer.',
        );
      }
      return evaluate(declarationUnit, expression);
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

  Future<Map<String, Object?>> _evaluateMapLiteral(
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

  void _validateSchemaOrContent(
    ResolvedUnitResult unit,
    Map<String, Object?> value, {
    required String scope,
  }) {
    final schema = value['schema'];
    final content = value['content'];
    if (schema == null && content == null) {
      throw RouteScanException(
        '$scope in `${unit.path}` requires `schema` or `content`.',
      );
    }
    if (schema != null && content != null) {
      throw RouteScanException(
        '$scope in `${unit.path}` cannot have both `schema` and `content`.',
      );
    }
    if (content case final Map<String, Object?> map when map.length != 1) {
      throw RouteScanException(
        '$scope.content in `${unit.path}` must contain exactly one media type entry.',
      );
    }
  }

  void _validateExclusiveFields(
    ResolvedUnitResult unit,
    Map<String, Object?> value, {
    required String first,
    required String second,
    required String scope,
  }) {
    if (value[first] != null && value[second] != null) {
      throw RouteScanException(
        '$scope.$first and $scope.$second are mutually exclusive in `${unit.path}`.',
      );
    }
  }

  Future<Expression?> _initializerForElement(Element element) async {
    final normalized = normalizeReferencedElement(element);
    if (normalized is! TopLevelVariableElement) {
      return null;
    }
    final library = normalized.library;
    final resolvedLibrary = await _context.resolvedLibrary(library);
    final declaration = resolvedLibrary.getFragmentDeclaration(
      normalized.firstFragment,
    );
    final node = declaration?.node;
    if (node is VariableDeclaration) {
      return node.initializer;
    }
    return null;
  }
}
