import 'package:json_annotation/json_annotation.dart';
import 'package:simple_todo/utils/uuid.dart';
part 'todo_model.g.dart';

@JsonSerializable()
class Todo {
  final String id, parent;
  final String name;
  @JsonKey(name: 'completed')
  final int isCompleted;

  Todo(this.name, {required this.parent, this.isCompleted = 0, String? id})
      : this.id = id ?? Uuid().generateV4();

  Todo copy({String? name, int? isCompleted, String? id, String? parent}) {
    return Todo(
      name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
