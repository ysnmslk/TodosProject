import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moriartytodos/riverpod_providers/routines_riverpod.dart';

class RTListItemWidget extends ConsumerStatefulWidget {
  RTListItemWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RTListItemWidget();
}

class _RTListItemWidget extends ConsumerState<RTListItemWidget> {
  late FocusNode _textFocusNode;
  late TextEditingController _textController;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _textFocusNode = FocusNode();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoutinesItem = ref.watch(currentRoutineProvider);
    return Focus(
      onFocusChange: (isFocused) {
        if (!isFocused) {
          setState(() {
            _hasFocus = false;
          });
          ref.read(routineListProvider.notifier).edit(
              id: currentRoutinesItem.id, newDescription: _textController.text);
        }
      },
      child: ListTile(
        onTap: () {
          setState(() {
            _hasFocus = true;
          });
          _textFocusNode.requestFocus();
          _textController.text = currentRoutinesItem.description;
        },
        leading: Checkbox(
            value: currentRoutinesItem.completed,
            onChanged: (value) {
              ref
                  .read(routineListProvider.notifier)
                  .toggle(currentRoutinesItem.id);
            }),
        title: _hasFocus
            ? TextField(
                controller: _textController,
                focusNode: _textFocusNode,
              )
            : Text(currentRoutinesItem.description),
      ),
    );
  }
}
