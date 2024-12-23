import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

@freezed
class TodoModel with _$TodoModel, _$TodoModel   {
  const factory TodoModel({
    int? id,
    required String title,
    @Default('')
    String description,
    @Default(false)
    @JsonKey(fromJson: _boolFromJson, toJson: _boolToJson)
    bool isCompleted,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  const TodoModel._();

  Todo entity() => Todo(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
      );

}

// Custom JSON conversion methods
bool _boolFromJson(dynamic value) {
  if (value is bool) {
    return value;
  } else if (value is int) {
    return value == 1; // Assuming 1 is true and 0 is false
  }
  throw ArgumentError('Invalid type for isCompleted: $value');
}

int _boolToJson(bool value) => value ? 1 : 0; // Optional: Serialize as int
