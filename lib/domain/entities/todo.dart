import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

@freezed
class Todo with _$Todo {
  // final int? id;
  // final String title;
  // final bool isCompleted;
  //
  // Todo(
  //   this.id,
  //   this.title,
  //   this.isCompleted,
  // );

  factory Todo({
    int? id,
    required String title,
    @Default(false) bool isCompleted,
  }) = _Todo;
}
