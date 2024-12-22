import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc(this.repository) : super(TodoInitial()) {
    on<LoadTodosEvent>((event, emit) async {
      emit(TodoLoading());
      final todos = await repository.getTodos();
      emit(TodoLoaded(todos: todos));
    });

    on<AddTodoEvent>((event, emit) async {
      await repository.addTodo(event.todo);
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
