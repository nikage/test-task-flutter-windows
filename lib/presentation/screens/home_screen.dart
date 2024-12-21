
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: const Center(
        child: Text('To-Do List will be displayed here'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add task functionality here
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
