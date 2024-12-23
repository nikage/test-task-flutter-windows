import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

@freezed
class Todo with _$Todo {
  factory Todo({
    int? id,
    required String title,
    @Default("") String description,
    @Default(false) bool isCompleted,
  }) = _Todo;
}
