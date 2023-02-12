import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moriartytodos/DailyRoutines/widgets/routi%C4%B1nes_list_item_widget.dart';
import 'package:moriartytodos/DailyRoutines/widgets/title_widgets.dart';
import 'package:moriartytodos/DailyRoutines/widgets/tool_bar_widgets.dart';
import 'package:moriartytodos/riverpod_providers/routines_riverpod.dart';

class DailyRoutineMainScreen extends ConsumerWidget {
  final newRoutinesController = TextEditingController();
  DailyRoutineMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var allroutines = ref.watch(filteredRoutinesList);
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: (){}, icon: const Icon(Icons.back_hand_sharp))

      ],
      backgroundColor: Colors.orange),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          const TitleWidgets(),
          TextField(
            controller: newRoutinesController,
            decoration:
                const InputDecoration(labelText: 'Hayatına bir Rutin ekle'),
            onSubmitted: (newRoutines) {
              ref.watch(routineListProvider.notifier).addRoutines(newRoutines);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ToolBarWidgets(),
          for (var i = 0; i < allroutines!.length; i++)
            ProviderScope(overrides: [
              currentRoutineProvider.overrideWithValue(allroutines[i])
            ], child: RTListItemWidget()),
        ],
      ),
    );
  }
}
