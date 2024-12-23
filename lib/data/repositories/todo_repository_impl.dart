import 'package:injectable/injectable.dart';

import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../models/todo_model.dart';

@LazySingleton(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  TodoLocalDataSource dataSource;

  TodoRepositoryImpl({required TodoLocalDataSource this.dataSource}) {
    // dataSource = DI<TodoLocalDataSource>();
  }

  @override
  Future<List<Todo>> getTodos() async {
    final result = await dataSource.getTodos();
    return result.map((map) => TodoModel.fromJson(map).entity()).toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final model = TodoModel(
      id: null,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
    try {
      await dataSource.insertTodo(model.toJson());
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final model = TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
    await dataSource.updateTodo(model.toJson(), todo.id!);
  }

  @override
  Future<void> deleteTodo(int id) async {
    await dataSource.deleteTodo(id);
  }
}
