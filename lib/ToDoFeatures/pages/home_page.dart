import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:moriartytodos/DailyRoutines/pages/DailyRoutineMainScreen.dart';
import 'package:moriartytodos/ToDoFeatures/data/local_storage.dart';
import 'package:moriartytodos/ToDoFeatures/helper/translation_helper.dart';
import 'package:moriartytodos/ToDoFeatures/models/task_model.dart';
import 'package:moriartytodos/ToDoFeatures/widgets/task_list_item.dart';
import 'package:moriartytodos/main.dart';
import 'package:easy_localization/src/public_ext.dart';
import '../widgets/custom_search_delegate.dart';

class ToDoMainScreen extends StatefulWidget {
  const ToDoMainScreen({Key? key}) : super(key: key);

  @override
  State<ToDoMainScreen> createState() => _ToDoMainScreenState();
}

class _ToDoMainScreenState extends State<ToDoMainScreen> {
  late List<TaskModel> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locater<LocalStorage>();
    _allTasks = <TaskModel>[];
    _getAllTaskFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              _showAddTaskSheet();
            },
            child: const Icon(Icons.add,size: 24),
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: GestureDetector(
            onTap: () {
              _showAddTaskSheet();
            },
            child: const Text(
              'title',
              style: TextStyle(
                color: Colors.black,
              ),
            ).tr(),
          ),
          centerTitle: false,
          actions: [
            IconButton(
                onPressed: () {
                  _showSearchPage();
                },
                icon: const Icon(
                  Icons.search_outlined,
                  color: Colors.black,
                )),
            IconButton(
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).push
                    (MaterialPageRoute(builder: (context)=> DailyRoutineMainScreen()));
                },
                icon: const Icon(Icons.access_alarms_sharp, )),
          ],
        ),
        body: _allTasks.isEmpty
            ? Center(
                child: const Text('empty_task_list').tr(),
              )
            : ListView.builder(
                itemBuilder: (context, index) {
                  var oankiListeElemani = _allTasks[index];
                  return Dismissible(
                    background: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 7),
                        const Text('remove_task').tr(),
                      ],
                    ),
                    key: UniqueKey(),
                    //Key(_oankiListeElemani.id),
                    // Uniquekey( sorunu çözüyor ama silme yaptırmıyo

                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        _allTasks.remove(context);
                        _localStorage.deleteTask(
                            taskModel: oankiListeElemani);
                      });
                    },
                    child: TaskItem(task: oankiListeElemani),
                  );
                },
                itemCount: _allTasks.length,
              ));
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: TextField(
              style: const TextStyle(fontSize: 22),
              decoration: InputDecoration(
                  hintText: 'add_task'.tr(), border: InputBorder.none),
              onSubmitted: (value) {
                Navigator.of(context).pop();
                if (value.length > 3) {
                  DatePicker.showTimePicker(context,
                      showSecondsColumn: false,
                      locale: TranslationHelper.getDevicelanguage(context),
                      onConfirm: (time) async {
                    var yeniEklenecekGorev =
                        TaskModel.create(name: value, createdAt: time);
                    _allTasks.insert(0, yeniEklenecekGorev);
                    await _localStorage.addTask(taskModel: yeniEklenecekGorev);
                    setState(() {});
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  _getAllTaskFromDB() async {
    _allTasks = await _localStorage.getAllTask();

    setState(() {});
  }

  Future<void> _showSearchPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTaskFromDB();
  }
}
