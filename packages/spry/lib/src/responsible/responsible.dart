import 'dart:typed_data';

import '../event/event.dart';
import '../http/response.dart';
import '../locals/locals+get_or_set.dart';

abstract interface class Responsible {
  Future<Response> createResponse(Event event);

  static void add<T>(Event event, Responsible Function(T value) factory) {
    if (has(event, factory)) {
      return;
    }

    event.responsibleNodes.add(_ResponsibleNode(
      id: factory,
      match: (value) => value is T,
      create: (value) => factory(value),
    ));
  }

  static bool has<T>(Event event, Responsible Function(T value) factory) {
    return event.responsibleNodes.any((node) => node.id == factory);
  }

  static Responsible of<T>(Event event, T value) {
    final node =
        event.responsibleNodes.firstWhereOrNull((node) => node.match(value));
    if (node != null) {
      return node.create(value);
    }

    return switch (value) {
      Responsible responsible => responsible,
      Stream<Uint8List> raw => _RawResponsible(raw),
      Stream<List<int>> raw => _RawResponsible(raw.map(Uint8List.fromList)),
      Map value => _JsonResponsible(value),
      List value => _JsonResponsible(value),
      String text => _TextResponsible(text),
      num(toString: final toString) => _TextResponsible(toString()),
      bool(toString: final toString) => _TextResponsible(toString()),
      _ => _fallbackOf(value),
    };
  }

  static Responsible _fallbackOf(value) {
    try {
      return _JsonResponsible(value.toJson());
    } catch (_) {}

    throw Exception('The ${value.runtimeType} value is not responsible.');
  }
}

class _ResponsibleNode {
  const _ResponsibleNode({
    required this.id,
    required this.match,
    required this.create,
  });

  final Object id;
  final bool Function(dynamic value) match;
  final Responsible Function(dynamic value) create;
}

class _TextResponsible implements Responsible {
  const _TextResponsible(this.text);

  final String text;

  @override
  Future<Response> createResponse(Event event) async {
    return Response.text(text);
  }
}

class _RawResponsible implements Responsible {
  const _RawResponsible(this.raw);

  final Stream<Uint8List> raw;

  @override
  Future<Response> createResponse(Event event) async {
    return Response(raw);
  }
}

class _JsonResponsible implements Responsible {
  const _JsonResponsible(this.value);

  final dynamic value;

  @override
  Future<Response> createResponse(Event event) async {
    return Response.json(value);
  }
}

extension on Event {
  List<_ResponsibleNode> get responsibleNodes {
    return locals.getOrSet<List<_ResponsibleNode>>(
      #spry.responsible.nodes,
      () => <_ResponsibleNode>[],
    );
  }
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}
