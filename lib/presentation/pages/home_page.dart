import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return ListTile(
                  title: Text(todo.title),
                  trailing: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) {
                      context.read<TodoBloc>().add(
                            UpdateTodoEvent(
                              todo.copyWith(isCompleted: value ?? false),
                            ),
                          );
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No todos found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new todo logic
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
