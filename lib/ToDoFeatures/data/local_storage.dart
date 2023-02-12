import 'package:hive/hive.dart';
import 'package:moriartytodos/ToDoFeatures/models/task_model.dart';

abstract class LocalStorage {
  Future<void> addTask({required TaskModel taskModel});
  Future<TaskModel?> getTask({required String id});
  Future<List<TaskModel>> getAllTask();
  Future<bool> deleteTask({required TaskModel taskModel});
  Future<TaskModel> updateTask({required TaskModel taskModel});
}

class HiveLocalStorage extends LocalStorage {
  late Box<TaskModel> _taskBox;
  @override
  Future<void> addTask({required TaskModel taskModel}) async {
    await _taskBox.put(taskModel.id, taskModel);
  }

  HiveLocalStorage() {
    _taskBox = Hive.box<TaskModel>('tasks');
  }
  @override
  Future<bool> deleteTask({required TaskModel taskModel}) async {
    await taskModel.delete();
    return true;
  }

  @override
  Future<List<TaskModel>> getAllTask() async {
    List<TaskModel> allTask = <TaskModel>[];
    allTask = _taskBox.values.toList();

    if (allTask.isNotEmpty) {
      allTask.sort(
          (TaskModel a, TaskModel b) => b.createdAt.compareTo(a.createdAt));
    }
    return allTask;
  }

  @override
  Future<TaskModel?> getTask({required String id}) async {
    if (_taskBox.containsKey(id)) {
      return _taskBox.get(id);
    } else {
      return null;
    }
  }

  @override
  Future<TaskModel> updateTask({required TaskModel taskModel}) async {
    await taskModel.save();
    return taskModel;
  }
}
