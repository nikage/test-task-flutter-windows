import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/datasources/todo_local_data_source.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../presentation/bloc/todo_bloc.dart';
import '../presentation/pages/home_page.dart';

void main() {
  final dataSource = TodoLocalDataSource.instance;
  final repository = TodoRepositoryImpl(dataSource);

  runApp(
    MyApp(repository: repository),
  );
}

class MyApp extends StatelessWidget {
  final TodoRepositoryImpl repository;

  const MyApp({Key? key, required this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      home: BlocProvider(
        create: (_) => TodoBloc(repository)..add(LoadTodosEvent()),
        child: const HomePage(),
      ),
    );
  }
}
