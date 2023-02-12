import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moriartytodos/DailyRoutines/models/routines_model.dart';
import 'package:moriartytodos/riverpod_providers/routines_riverpod.dart';

class ToolBarWidgets extends ConsumerWidget {
  ToolBarWidgets({Key? key}) : super(key: key);
  var _currentFilter = RoutinesListFilters.all;

  Color changeTextColor(RoutinesListFilters filt) {
    return _currentFilter == filt ? Colors.orange : Colors.black;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onCompletedRoutineCount = ref.watch(unCompletedRoutineCount);
    _currentFilter = ref.watch(routinesListFilter);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            onCompletedRoutineCount == 0
                ? "Bugün sana tatil"
                : "$onCompletedRoutineCount görev tamamlanmadı",
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Tooltip(
          message: 'All Routines',
          child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: changeTextColor(RoutinesListFilters.all),
              ),
              onPressed: () {
                // ref.read(routineListProvider.notifier).state =
                // RoutinesListFilters.all;
              },
              child: const Text('')),
        ),
        Tooltip(
          message: 'Uncompleted Routines',
          child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: changeTextColor(RoutinesListFilters.active),
              ),
              onPressed: () {},
              child: const Text('Undone')),
        ),
        Tooltip(
          message: 'Completed Routines',
          child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: changeTextColor(RoutinesListFilters.completed),
              ),
              onPressed: () {},
              child: const Text('Done')),
        ),
      ],
    );
  }
}
