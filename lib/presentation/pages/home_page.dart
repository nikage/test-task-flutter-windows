import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/todo.dart';
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
                  title: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: todo.title,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                          ),
                          onChanged: (newValue) {
                            context.read<TodoBloc>().add(
                                  UpdateTodoEvent(
                                    todo.copyWith(title: newValue),
                                  ),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: todo.description,
                          decoration: const InputDecoration(
                            hintText: 'Description',
                          ),
                          onChanged: (newValue) {
                            context.read<TodoBloc>().add(
                                  UpdateTodoEvent(
                                    todo.copyWith(description: newValue),
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
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
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController titleController = TextEditingController();
                final TextEditingController descriptionController = TextEditingController();

                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final title = titleController.text;
                        final description = descriptionController.text;

                        if (title.isNotEmpty && description.isNotEmpty) {
                          final newTodo = Todo(
                            title: title,
                            description: description,
                            isCompleted: false,
                          );

                          context.read<TodoBloc>().add(AddTodoEvent(newTodo));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
    );
  }
}
