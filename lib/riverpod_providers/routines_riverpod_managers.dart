import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moriartytodos/DailyRoutines/models/routines_model.dart';
import 'package:uuid/uuid.dart';

class RoutinesManager extends StateNotifier<List<RoutinesModel>> {
  RoutinesManager([List<RoutinesModel>? initialRoutines])
      : super(initialRoutines ?? []);

  void addRoutines(String description) {
    var eklenecekRoutine =
        RoutinesModel(id: const Uuid().v4(), description: description);
    state = [...state, eklenecekRoutine];
  }

  void toggle(String id) {
    state = [
      for (var routines in state)
        if (routines.id == id)
          RoutinesModel(
              id: routines.id,
              description: routines.description,
              completed: !routines.completed)
        else
          routines,
    ];
  }

  void edit({required String id, required String newDescription}) {
    state = [
      for (var routine in state)
        if (routine.id == id)
          RoutinesModel(
              id: routine.id,
              completed: routine.completed,
              description: newDescription)
        else
          routine
    ];
  }

  void remove(RoutinesModel silinecekRoutine) {
    state =
        state.where((element) => element.id != silinecekRoutine.id).toList();
  }

  int onCompletedRoutineCount() {
    return state.where((element) => !element.completed).length;
  }
}
