import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:todo_app/injectable.dart';

import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

@lazySingleton
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc()
      : this.repository = DI<TodoRepository>(),
        super(TodoInitial()) {
    on<LoadTodosEvent>((event, emit) async {
      emit(TodoLoading());
      final todos = await repository.getTodos();
      emit(TodoLoaded(todos: todos));
    });

    on<AddTodoEvent>((event, emit) async {
      try {
        await repository.addTodo(event.todo);
      } catch (e) {
        print(e);
      }
      add(LoadTodosEvent());
    });

    on<UpdateTodoEvent>((event, emit) async {
      await repository.updateTodo(event.todo);
      add(LoadTodosEvent());
    });

    on<DeleteTodoEvent>((event, emit) async {
      await repository.deleteTodo(event.id);
      add(LoadTodosEvent());
    });
  }
}
