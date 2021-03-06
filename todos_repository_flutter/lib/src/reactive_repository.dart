// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:todos_repository/todos_repository.dart';

/**
 * 数据的具体处理类
 * 增删改查的操作
 *
 */
class ReactiveRepositoryFlutter implements ReactiveRepository<ChannelsEntity> {
  final ChannelsRepository _repository;
  final BehaviorSubject<List<ChannelsEntity>> _subject;
  bool _loaded = false;

  ReactiveRepositoryFlutter({
    @required ChannelsRepository repository,
    List<ChannelsEntity> seedValue,
  })  : this._repository = repository,
        this._subject =
            BehaviorSubject<List<ChannelsEntity>>(seedValue: seedValue);

  @override
  Future<void> add(t) async {
    _subject.add(List.unmodifiable([]
      ..addAll(_subject.value ?? [])
      ..add(t)));

    await _repository.saveChannel(_subject.value);
  }

  @override
  Future<void> delete(List<String> idList) async {
    _subject.add(List<ChannelsEntity>.unmodifiable(_subject.value
        .fold<List<ChannelsEntity>>(<ChannelsEntity>[], (pre, entity) {
      return idList.contains(entity.id) ? pre : (pre..add(entity));
    })));
    await _repository.saveChannel(_subject.value);
  }

  @override
  Stream<List<ChannelsEntity>> data() {
    if (!_loaded) _loadData();
    return _subject.stream;
  }

  void _loadData() {
    _loaded = true;
    _repository.loadChannels().then((entitys) {
      _subject.add(List<ChannelsEntity>.unmodifiable(
          []..addAll(_subject.value ?? [])..addAll(entitys)));
    });
  }

  @override
  Future<void> update(ChannelsEntity t) async {
    _subject.add(
      List<ChannelsEntity>.unmodifiable(
          _subject.value.fold<List<ChannelsEntity>>(
        <ChannelsEntity>[],
        (prev, entity) => prev..add(entity.id == t.id ? update : entity),
      )),
    );

    await _repository.saveChannel(_subject.value);
  }
}

/// A class that glues together our local file storage and web client. It has a
/// clear responsibility: Load Todos and Persist todos.
class ReactiveTodosRepositoryFlutter implements ReactiveTodosRepository {
  final TodosRepository _repository;
  final BehaviorSubject<List<TodoEntity>> _subject;
  bool _loaded = false;

  ReactiveTodosRepositoryFlutter({
    @required TodosRepository repository,
    List<TodoEntity> seedValue,
  })  : this._repository = repository,
        this._subject = BehaviorSubject<List<TodoEntity>>(seedValue: seedValue);

  @override
  Future<void> addNewTodo(TodoEntity todo) async {
    _subject.add(List.unmodifiable([]
      ..addAll(_subject.value ?? [])
      ..add(todo)));

    await _repository.saveTodos(_subject.value);
  }

  @override
  Future<void> deleteTodo(List<String> idList) async {
    _subject.add(
      List<TodoEntity>.unmodifiable(_subject.value.fold<List<TodoEntity>>(
        <TodoEntity>[],
        (prev, entity) {
          return idList.contains(entity.id) ? prev : (prev..add(entity));
        },
      )),
    );

    await _repository.saveTodos(_subject.value);
  }

  @override
  Stream<List<TodoEntity>> todos() {
    if (!_loaded) _loadTodos();

    return _subject.stream;
  }

  void _loadTodos() {
    _loaded = true;

    _repository.loadTodos().then((entities) {
      _subject.add(List<TodoEntity>.unmodifiable(
        []..addAll(_subject.value ?? [])..addAll(entities),
      ));
    });
  }

  @override
  Future<void> updateTodo(TodoEntity update) async {
    _subject.add(
      List<TodoEntity>.unmodifiable(_subject.value.fold<List<TodoEntity>>(
        <TodoEntity>[],
        (prev, entity) => prev..add(entity.id == update.id ? update : entity),
      )),
    );

    await _repository.saveTodos(_subject.value);
  }
}
