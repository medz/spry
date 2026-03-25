// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';

import 'scanner_exception.dart';

final class ResolvedScannerContext {
  ResolvedScannerContext(String rootDir)
    : _collection = AnalysisContextCollection(includedPaths: [rootDir]);

  final AnalysisContextCollection _collection;
  final Map<String, Future<ResolvedUnitResult>> _unitCache = {};
  final Map<AnalysisSession, Future<SprySemanticContracts>> _contractsCache =
      Map.identity();
  final Map<LibraryElement, Future<ResolvedLibraryResult>> _libraryCache =
      Map.identity();

  Future<void> dispose() => _collection.dispose();

  Future<ResolvedUnitResult> resolvedUnit(String path) {
    return _unitCache.putIfAbsent(path, () async {
      final result = await _collection
          .contextFor(path)
          .currentSession
          .getResolvedUnit(path);
      if (result is ResolvedUnitResult) {
        return result;
      }
      throw RouteScanException(
        'Failed to resolve `$path` for semantic scanning: ${result.runtimeType}.',
      );
    });
  }

  Future<ResolvedLibraryResult> resolvedLibrary(LibraryElement library) {
    return _libraryCache.putIfAbsent(library, () async {
      final result = await library.session.getResolvedLibraryByElement(library);
      if (result is ResolvedLibraryResult) {
        return result;
      }
      throw RouteScanException(
        'Failed to resolve library `${library.uri}` for semantic scanning: ${result.runtimeType}.',
      );
    });
  }

  Future<SprySemanticContracts> contractsFor(ResolvedUnitResult unit) {
    return _contractsCache.putIfAbsent(
      unit.session,
      () => _loadContracts(unit.session),
    );
  }

  Future<SprySemanticContracts> _loadContracts(AnalysisSession session) async {
    Future<LibraryElement> libraryByUri(String uri) async {
      final result = await session.getLibraryByUri(uri);
      if (result is LibraryElementResult) {
        return result.element;
      }
      throw RouteScanException(
        'Failed to resolve semantic contract library `$uri`: ${result.runtimeType}.',
      );
    }

    final openApiLibrary = await libraryByUri('package:spry/openapi.dart');
    final spryLibrary = await libraryByUri('package:spry/spry.dart');
    final osrvLibrary = await libraryByUri('package:osrv/osrv.dart');

    final openApiElement =
        openApiLibrary.exportNamespace.definedNames2['OpenAPI'];
    final openApiComponentsElement =
        openApiLibrary.exportNamespace.definedNames2['OpenAPIComponents'];
    final handlerAlias = spryLibrary.exportNamespace.definedNames2['Handler'];
    final middlewareAlias =
        spryLibrary.exportNamespace.definedNames2['Middleware'];
    final errorHandlerAlias =
        spryLibrary.exportNamespace.definedNames2['ErrorHandler'];
    final serverHookAlias =
        osrvLibrary.exportNamespace.definedNames2['ServerHook'];
    final serverErrorHookAlias =
        osrvLibrary.exportNamespace.definedNames2['ServerErrorHook'];

    if (openApiElement is! ExtensionTypeElement ||
        openApiComponentsElement is! ExtensionTypeElement ||
        handlerAlias is! TypeAliasElement ||
        middlewareAlias is! TypeAliasElement ||
        errorHandlerAlias is! TypeAliasElement ||
        serverHookAlias is! TypeAliasElement ||
        serverErrorHookAlias is! TypeAliasElement) {
      throw const RouteScanException(
        'Failed to load Spry semantic contracts from analyzer exports.',
      );
    }

    return SprySemanticContracts(
      openApiElement: openApiElement,
      openApiComponentsElement: openApiComponentsElement,
      handlerType: handlerAlias.aliasedType,
      middlewareType: middlewareAlias.aliasedType,
      errorHandlerType: errorHandlerAlias.aliasedType,
      serverHookType: serverHookAlias.aliasedType,
      serverErrorHookType: serverErrorHookAlias.aliasedType,
    );
  }
}

final class SprySemanticContracts {
  const SprySemanticContracts({
    required this.openApiElement,
    required this.openApiComponentsElement,
    required this.handlerType,
    required this.middlewareType,
    required this.errorHandlerType,
    required this.serverHookType,
    required this.serverErrorHookType,
  });

  final ExtensionTypeElement openApiElement;
  final ExtensionTypeElement openApiComponentsElement;
  final DartType handlerType;
  final DartType middlewareType;
  final DartType errorHandlerType;
  final DartType serverHookType;
  final DartType serverErrorHookType;
}

({String filePath, String name, Element element, DartType type})?
findTopLevelBinding(ResolvedUnitResult unit, String name) {
  for (final declaration in unit.unit.declarations) {
    if (declaration is FunctionDeclaration &&
        declaration.name.lexeme == name &&
        declaration.declaredFragment != null) {
      final element = declaration.declaredFragment!.element;
      return (
        filePath: unit.path,
        name: name,
        element: element,
        type: element.type,
      );
    }
    if (declaration is TopLevelVariableDeclaration) {
      for (final variable in declaration.variables.variables) {
        if (variable.name.lexeme == name && variable.declaredFragment != null) {
          final element = variable.declaredFragment!.element;
          return (
            filePath: unit.path,
            name: name,
            element: element,
            type: element.type,
          );
        }
      }
    }
  }
  return null;
}

bool isAssignableTo(
  TypeSystem typeSystem,
  DartType fromType,
  DartType toType,
) => typeSystem.isAssignableTo(fromType, toType);

Element normalizeReferencedElement(Element? element) {
  if (element is PropertyAccessorElement) {
    return element.variable;
  }
  return element!;
}

String describeElement(Element? element) {
  if (element == null) {
    return 'null';
  }
  return '${element.runtimeType} `${element.displayName}` from `${element.library?.uri}`';
}
