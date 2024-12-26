import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/todo.dart';
import '../../injectable.dart';
import '../bloc/todo_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String titleFilter = '';
  String descriptionFilter = '';
  String statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Title Filter
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Title',
                    ),
                    onChanged: (value) {
                      setState(() {
                        titleFilter = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Description Filter
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Description',
                    ),
                    onChanged: (value) {
                      setState(() {
                        descriptionFilter = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Status Filter
                DropdownButton<String>(
                  value: statusFilter,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        statusFilter = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'Incomplete', child: Text('Incomplete')),
                  ],
                ),
              ],
            ),
          ),
          // To-Do List
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TodoLoaded) {
                  // Apply filters
                  final filteredTodos = state.todos.where((todo) {
                    final matchesTitle = todo.title
                        .toLowerCase()
                        .contains(titleFilter);
                    final matchesDescription = todo.description
                        .toLowerCase()
                        .contains(descriptionFilter);
                    final matchesStatus = (statusFilter == 'All') ||
                        (statusFilter == 'Completed' && todo.isCompleted) ||
                        (statusFilter == 'Incomplete' && !todo.isCompleted);

                    return matchesTitle &&
                        matchesDescription &&
                        matchesStatus;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                DI<TodoBloc>().add(DeleteTodoEvent(todo.id!));
                              },
                            ),
                            Checkbox(
                              value: todo.isCompleted,
                              onChanged: (value) {
                                context.read<TodoBloc>().add(
                                  UpdateTodoEvent(
                                    todo.copyWith(
                                        isCompleted: value ?? false),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('No todos found'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController titleController =
              TextEditingController();
              final TextEditingController descriptionController =
              TextEditingController();

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

                        DI<TodoBloc>().add(AddTodoEvent(newTodo));
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