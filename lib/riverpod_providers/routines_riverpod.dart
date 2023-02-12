import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moriartytodos/riverpod_providers/routines_riverpod_managers.dart';
import 'package:uuid/uuid.dart';
import '../DailyRoutines/models/routines_model.dart';

enum RoutinesListFilters { all, active, completed }

final routinesListFilter =
    StateProvider<RoutinesListFilters>((ref) => RoutinesListFilters.all);

final routineListProvider =
    StateNotifierProvider<RoutinesManager, List<RoutinesModel>>((ref) {
  return RoutinesManager([
    RoutinesModel(id: const Uuid().v4(), description: 'Spora Git'),
    RoutinesModel(id: const Uuid().v4(), description: 'Ders  Çalış'),
    RoutinesModel(id: const Uuid().v4(), description: 'Alışveriş'),
    RoutinesModel(id: const Uuid().v4(), description: 'Flutter Çalış'),
  ]);
});

final filteredRoutinesList = Provider<List<RoutinesModel>?>((ref) {
  final filter = ref.watch(routinesListFilter);
  final routineList = ref.watch(routineListProvider);

  switch (filter) {
    case RoutinesListFilters.all:
      return routineList;
    case RoutinesListFilters.completed:
      return routineList.where((element) => element.completed).toList();
    case RoutinesListFilters.active:
      return routineList.where((element) => !element.completed).toList();
  }
});

final unCompletedRoutineCount = Provider<int>((ref) {
  final allRoutine = ref.watch(routineListProvider);
  final count = allRoutine.where((element) => !element.completed).length;
  return count;
});

final currentRoutineProvider = Provider<RoutinesModel>((ref) {
  throw UnimplementedError();
});
