import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/injectable.dart';

import '../../domain/entities/todo.dart';
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

  String sortBy = 'Title';
  bool isAscending = true;

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
          // To-Do Table
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TodoLoaded) {
                  var filteredTodos = state.todos.where((todo) {
                    final matchesTitle =
                    todo.title.toLowerCase().contains(titleFilter);
                    final matchesDescription =
                    todo.description.toLowerCase().contains(descriptionFilter);
                    final matchesStatus = (statusFilter == 'All') ||
                        (statusFilter == 'Completed' && todo.isCompleted) ||
                        (statusFilter == 'Incomplete' && !todo.isCompleted);

                    return matchesTitle && matchesDescription && matchesStatus;
                  }).toList();

                  // Apply sorting
                  filteredTodos.sort((a, b) {
                    int comparison = 0;
                    switch (sortBy) {
                      case 'Title':
                        comparison = a.title.compareTo(b.title);
                        break;
                      case 'Description':
                        comparison = a.description.compareTo(b.description);
                        break;
                      case 'Status':
                        comparison = a.isCompleted ? (b.isCompleted ? 0 : 1) : (b.isCompleted ? -1 : 0);
                        break;
                    }
                    return isAscending ? comparison : -comparison;
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: {
                          'Title': 0,
                          'Description': 1,
                          'Status': 2
                        }[sortBy],
                        sortAscending: isAscending,
                        columns: [
                          DataColumn(
                            label: const Text('Title'),
                            onSort: (columnIndex, _) {
                              setState(() {
                                sortBy = 'Title';
                                isAscending = !isAscending;
                              });
                            },
                          ),
                          DataColumn(
                            label: const Text('Description'),
                            onSort: (columnIndex, _) {
                              setState(() {
                                sortBy = 'Description';
                                isAscending = !isAscending;
                              });
                            },
                          ),
                          DataColumn(
                            label: const Text('Status'),
                            onSort: (columnIndex, _) {
                              setState(() {
                                sortBy = 'Status';
                                isAscending = !isAscending;
                              });
                            },
                          ),
                          const DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredTodos.map((todo) {
                          return DataRow(
                            cells: [
                              DataCell(Text(todo.title)),
                              DataCell(Text(todo.description)),
                              DataCell(
                                Text(todo.isCompleted ? 'Completed' : 'Incomplete'),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditDialog(context, todo);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        DI<TodoBloc>().add(
                                          DeleteTodoEvent(todo.id!),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
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

  void _showEditDialog(BuildContext context, Todo todo) {
    final TextEditingController titleController =
    TextEditingController(text: todo.title);
    final TextEditingController descriptionController =
    TextEditingController(text: todo.description);
    bool isCompleted = todo.isCompleted;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Completed:'),
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          isCompleted = value;
                        });
                      }
                    },
                  ),
                ],
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
                final updatedTodo = todo.copyWith(
                  title: titleController.text,
                  description: descriptionController.text,
                  isCompleted: isCompleted,
                );

                DI<TodoBloc>().add(UpdateTodoEvent(updatedTodo));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}