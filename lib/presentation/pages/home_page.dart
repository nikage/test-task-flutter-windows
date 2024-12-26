import 'package:fluent_ui/fluent_ui.dart';
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
    return FluentApp(
      theme: FluentThemeData(
        brightness: Brightness.light,
        acrylicBackgroundColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ScaffoldPage(
        header: const PageHeader(title: Text('To-Do List')),
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextBox(
                      placeholder: 'Filter by Title',
                      onChanged: (value) {
                        setState(() {
                          titleFilter = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextBox(
                      placeholder: 'Filter by Description',
                      onChanged: (value) {
                        setState(() {
                          descriptionFilter = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropDownButton(
                    title: Text(statusFilter),
                    items: [
                      MenuFlyoutItem(
                        text: const Text('All'),
                        onPressed: () {
                          setState(() {
                            statusFilter = 'All';
                          });
                        },
                      ),
                      MenuFlyoutItem(
                        text: const Text('Completed'),
                        onPressed: () {
                          setState(() {
                            statusFilter = 'Completed';
                          });
                        },
                      ),
                      MenuFlyoutItem(
                        text: const Text('Incomplete'),
                        onPressed: () {
                          setState(() {
                            statusFilter = 'Incomplete';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoading) {
                    return const Center(child: ProgressBar());
                  } else if (state is TodoLoaded) {
                    var filteredTodos = state.todos.where((todo) {
                      final matchesTitle =
                          todo.title.toLowerCase().contains(titleFilter);
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
                          comparison = a.isCompleted
                              ? (b.isCompleted ? 0 : 1)
                              : (b.isCompleted ? -1 : 0);
                          break;
                      }
                      return isAscending ? comparison : -comparison;
                    });

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        defaultColumnWidth: const FlexColumnWidth(),
                        border: TableBorder.all(color: Colors.grey),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: Colors.grey),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Title',
                                  style: FluentTheme.of(context)
                                      .typography
                                      .bodyStrong,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Description',
                                  style: FluentTheme.of(context)
                                      .typography
                                      .bodyStrong,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Status',
                                  style: FluentTheme.of(context)
                                      .typography
                                      .bodyStrong,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Actions',
                                  style: FluentTheme.of(context)
                                      .typography
                                      .bodyStrong,
                                ),
                              ),
                            ],
                          ),
                          ...filteredTodos.map(
                            (todo) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(todo.title),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(todo.description),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(todo.isCompleted
                                      ? 'Completed'
                                      : 'Incomplete'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Button(
                                        child: const Icon(FluentIcons.edit),
                                        onPressed: () {
                                          _showEditDialog(context, todo);
                                        },
                                      ),
                                      Button(
                                        child: const Icon(FluentIcons.delete),
                                        onPressed: () {
                                          DI<TodoBloc>()
                                              .add(DeleteTodoEvent(todo.id!));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No todos found'));
                },
              ),
            ),
          ],
        ),
        bottomBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FilledButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.3),
                builder: (context) {
                  final TextEditingController titleController =
                      TextEditingController();
                  final TextEditingController descriptionController =
                      TextEditingController();

                  return ContentDialog(
                    title: const Text('Add Todo'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextBox(
                          controller: titleController,
                          placeholder: 'Title',
                        ),
                        const SizedBox(height: 10),
                        TextBox(
                          controller: descriptionController,
                          placeholder: 'Description',
                        ),
                      ],
                    ),
                    actions: [
                      Button(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
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
            child: const Text('Add Todo'),
          ),
        ),
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
        return ContentDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBox(
                controller: titleController,
                placeholder: 'Title',
              ),
              const SizedBox(height: 10),
              TextBox(
                controller: descriptionController,
                placeholder: 'Description',
              ),
              const SizedBox(height: 10),
              ToggleSwitch(
                checked: isCompleted,
                onChanged: (value) {
                  setState(() {
                    isCompleted = value!;
                  });
                },
                content: const Text('Completed'),
              ),
            ],
          ),
          actions: [
            Button(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
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
