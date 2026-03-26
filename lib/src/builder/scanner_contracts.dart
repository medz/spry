// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/type.dart';

import 'route_tree.dart';
import 'scanner_exception.dart';
import 'scanner_semantics.dart';

Future<void> validateRouteHandler(
  ResolvedScannerContext context,
  String filePath,
) async {
  await _validateBinding(
    context,
    filePath,
    name: 'handler',
    expectedLabel: 'Spry Handler',
    contractType: (contracts) => contracts.handlerType,
  );
}

Future<void> validateMiddlewareHandler(
  ResolvedScannerContext context,
  String filePath,
) async {
  await _validateBinding(
    context,
    filePath,
    name: 'middleware',
    expectedLabel: 'Spry Middleware',
    contractType: (contracts) => contracts.middlewareType,
  );
}

Future<void> validateErrorHandler(
  ResolvedScannerContext context,
  String filePath,
) async {
  await _validateBinding(
    context,
    filePath,
    name: 'onError',
    expectedLabel: 'Spry ErrorHandler',
    contractType: (contracts) => contracts.errorHandlerType,
  );
}

Future<HooksEntry> scanHooksMetadata(
  ResolvedScannerContext context,
  String filePath,
) async {
  final unit = await context.resolvedUnit(filePath);
  final contracts = await context.contractsFor(unit);

  final onStart = findTopLevelBinding(unit, 'onStart');
  final onStop = findTopLevelBinding(unit, 'onStop');
  final onError = findTopLevelBinding(unit, 'onError');

  if (onStart case final binding?) {
    _ensureAssignable(
      unit,
      binding.type,
      contracts.serverHookType,
      filePath: filePath,
      exportName: 'onStart',
      expectedLabel: 'osrv ServerHook',
    );
  }
  if (onStop case final binding?) {
    _ensureAssignable(
      unit,
      binding.type,
      contracts.serverHookType,
      filePath: filePath,
      exportName: 'onStop',
      expectedLabel: 'osrv ServerHook',
    );
  }
  if (onError case final binding?) {
    _ensureAssignable(
      unit,
      binding.type,
      contracts.serverErrorHookType,
      filePath: filePath,
      exportName: 'onError',
      expectedLabel: 'osrv ServerErrorHook',
    );
  }

  return HooksEntry(
    filePath: filePath,
    hasOnStart: onStart != null,
    hasOnStop: onStop != null,
    hasOnError: onError != null,
  );
}

Future<void> _validateBinding(
  ResolvedScannerContext context,
  String filePath, {
  required String name,
  required String expectedLabel,
  required DartType Function(SprySemanticContracts contracts) contractType,
}) async {
  final unit = await context.resolvedUnit(filePath);
  final binding = findTopLevelBinding(unit, name);
  if (binding == null) {
    throw RouteScanException(
      'Expected top-level `$name` in `$filePath`, but none was found.',
    );
  }
  final contracts = await context.contractsFor(unit);
  _ensureAssignable(
    unit,
    binding.type,
    contractType(contracts),
    filePath: filePath,
    exportName: name,
    expectedLabel: expectedLabel,
  );
}

void _ensureAssignable(
  ResolvedUnitResult unit,
  DartType actualType,
  DartType expectedType, {
  required String filePath,
  required String exportName,
  required String expectedLabel,
}) {
  if (isAssignableTo(unit.typeSystem, actualType, expectedType)) {
    return;
  }
  throw RouteScanException(
    'Top-level `$exportName` in `$filePath` must be assignable to $expectedLabel; '
    'expected `$expectedType`, got `$actualType`.',
  );
}
