import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource dataSource;

  TodoRepositoryImpl(this.dataSource);

  @override
  Future<List<Todo>> getTodos() async {
    final result = await dataSource.getTodos();
    return result.map((map) => TodoModel.fromJson(map).entity()).toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final model = TodoModel(id: null, title: todo.title, isCompleted: todo.isCompleted);
    await dataSource.insertTodo(model.toJson());
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final model = TodoModel(id: todo.id, title: todo.title, isCompleted: todo.isCompleted);
    await dataSource.updateTodo(model.toJson(), todo.id!);
  }

  @override
  Future<void> deleteTodo(int id) async {
    await dataSource.deleteTodo(id);
  }
}
