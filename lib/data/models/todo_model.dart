import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo.dart';

part 'todo_model.freezed.dart';

part 'todo_model.g.dart';

@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    int? id,
    required String title,
    @Default(false) bool isCompleted,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  const TodoModel._();

  Todo entity() => Todo(
        id: id,
        title: title,
        isCompleted: isCompleted,
      );
}
