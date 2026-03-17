import 'dart:io';

import 'package:knex_dart_sqlite/knex_dart_sqlite.dart';

KnexSQLite? _db;

KnexSQLite get db {
  final current = _db;
  if (current == null) {
    throw StateError('Database has not been initialized.');
  }
  return current;
}

Future<void> openDatabase() async {
  if (_db != null) {
    return;
  }

  Directory('data').createSync(recursive: true);

  final database = await KnexSQLite.connect(filename: 'data/app.db');
  _db = database;

  await database.executeSchema((schema) {
    schema.createTableIfNotExists('todos', (table) {
      table.increments('id');
      table.string('title').notNullable();
      table.boolean('completed').notNullable().defaultTo(false);
      table.string('created_at').notNullable();
    });
  });

  final existing = await database.select(
    database.queryBuilder().table('todos').select(['id']).limit(1),
  );
  if (existing.isNotEmpty) {
    return;
  }

  final seededAt = DateTime.now().toUtc();
  for (final todo in [
    {
      'title': 'Ship runtime-specific examples',
      'completed': true,
      'created_at': seededAt
          .subtract(const Duration(minutes: 10))
          .toIso8601String(),
    },
    {
      'title': 'Add a Spry + knex_dart demo',
      'completed': false,
      'created_at': seededAt.toIso8601String(),
    },
  ]) {
    await database.insert(database.queryBuilder().table('todos').insert(todo));
  }
}

Future<void> closeDatabase() async {
  final current = _db;
  if (current == null) {
    return;
  }

  _db = null;
  await current.close();
}

Future<List<Map<String, dynamic>>> listTodos() async {
  final rows = await db.select(
    db
        .queryBuilder()
        .table('todos')
        .select(['id', 'title', 'completed', 'created_at'])
        .orderBy('id'),
  );
  return rows.map(_normalizeTodo).toList();
}

Future<Map<String, dynamic>> createTodo(String title) async {
  final cleanedTitle = title.trim();
  if (cleanedTitle.isEmpty) {
    throw ArgumentError.value(title, 'title', 'Title must not be empty.');
  }

  await db.insert(
    db.queryBuilder().table('todos').insert({
      'title': cleanedTitle,
      'completed': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }),
  );

  final rows = await db.select(
    db
        .queryBuilder()
        .table('todos')
        .select(['id', 'title', 'completed', 'created_at'])
        .orderBy('id', 'desc')
        .first(),
  );
  if (rows.isEmpty) {
    throw StateError('Todo insert did not produce a readable row.');
  }

  return _normalizeTodo(rows.first);
}

Future<Map<String, dynamic>?> toggleTodo(int id) async {
  final existingRows = await db.select(
    db
        .queryBuilder()
        .table('todos')
        .select(['id', 'title', 'completed', 'created_at'])
        .where('id', '=', id)
        .first(),
  );
  if (existingRows.isEmpty) {
    return null;
  }

  final existing = existingRows.first;
  await db.update(
    db.queryBuilder().table('todos').where('id', '=', id).update({
      'completed': !_asBool(existing['completed']),
    }),
  );

  final updatedRows = await db.select(
    db
        .queryBuilder()
        .table('todos')
        .select(['id', 'title', 'completed', 'created_at'])
        .where('id', '=', id)
        .first(),
  );
  if (updatedRows.isEmpty) {
    return null;
  }

  return _normalizeTodo(updatedRows.first);
}

Map<String, dynamic> _normalizeTodo(Map<String, dynamic> row) {
  return {
    'id': row['id'],
    'title': row['title'],
    'completed': _asBool(row['completed']),
    'createdAt': row['created_at'],
  };
}

bool _asBool(Object? value) {
  return switch (value) {
    final bool value => value,
    final num value => value != 0,
    final String value => value == '1' || value.toLowerCase() == 'true',
    _ => false,
  };
}
