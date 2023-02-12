import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:moriartytodos/DailyRoutines/pages/DailyRoutineMainScreen.dart';
import 'package:moriartytodos/ToDoFeatures/models/task_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'ToDoFeatures/data/local_storage.dart';
import 'ToDoFeatures/pages/home_page.dart';

final locater = GetIt.instance;

void setup() {
  locater.registerSingleton<LocalStorage>(HiveLocalStorage());
}

Future<void> setupHive() async {
  await Hive.initFlutter();
  // Hive.registerAdapter(TaskModelAdapter());
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  var taskBox = await Hive.openBox<TaskModel>('tasks');
  for (var task in taskBox.values) {
    if (task.createdAt.day != DateTime.now().day) {
      taskBox.delete(task.id);
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
// en tepedeki alanı transparant yapar.
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  await setupHive();
  setup();
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en', 'US'), Locale('tr', 'TR')],
    path: 'assets/translations', // <-- change the path of the translation files
    fallbackLocale: const Locale('en', 'US'),
    child: const ProviderScope(child: MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.deviceLocale,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          //primarySwatch: Colors.,
          ),
      home: const ToDoMainScreen(),
    );
  }
}
