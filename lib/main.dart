import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/injectable.dart';

import '../presentation/bloc/todo_bloc.dart';
import '../presentation/pages/home_page.dart';

void main() {
  configureDependencies();


  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  // final TodoRepository repository =  DI<TodoRepository>();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      home: BlocProvider(
        create: (_) => DI<TodoBloc>()..add(LoadTodosEvent()),
        child: const HomePage(),
      ),
    );
  }
}
