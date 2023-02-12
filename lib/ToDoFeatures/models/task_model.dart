import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  //
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  bool isCompleted;

  TaskModel(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.isCompleted});

  factory TaskModel.create({
    required String name,
    required DateTime createdAt,
  }) {
    return TaskModel(
        id: const Uuid().v1(),
        name: name,
        createdAt: createdAt,
        isCompleted: false);
  }
}
