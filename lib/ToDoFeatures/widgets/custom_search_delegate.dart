import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:moriartytodos/ToDoFeatures/data/local_storage.dart';
import 'package:moriartytodos/ToDoFeatures/models/task_model.dart';
import 'package:moriartytodos/main.dart';

import 'task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<TaskModel> allTasks;

  CustomSearchDelegate({required this.allTasks});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query.isEmpty ? null : query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
        onTap: () {
          close(context, null);
        },
        child: const Icon(
          Icons.arrow_back,
          color: Colors.black,
          size: 24,
        ));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<TaskModel> filteredList = allTasks
        .where(
            (gorev) => gorev.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredList.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              var oankiListeElemani = filteredList[index];
              return Dismissible(
                background: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 7),
                    const Text('remove_task').tr()
                  ],
                ),
                key: Key(oankiListeElemani.id),
                onDismissed: (direction) async {
                  filteredList.remove(index);
                  await locater<LocalStorage>()
                      .deleteTask(taskModel: oankiListeElemani);
                },
                child: TaskItem(task: oankiListeElemani),
              );
            },
            itemCount: filteredList.length,
          )
        : Center(
            child: const Text('search_not_found').tr(),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
