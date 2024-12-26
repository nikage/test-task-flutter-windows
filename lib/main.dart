import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';
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

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      localizationsDelegates: const [
        FluentLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Add other supported locales here
      ],
      theme: FluentThemeData(
        brightness: Brightness.light,
        acrylicBackgroundColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: BlocProvider(
        create: (_) => DI<TodoBloc>()..add(LoadTodosEvent()),
        child: const HomePage(),
      ),
    );
  }
}
