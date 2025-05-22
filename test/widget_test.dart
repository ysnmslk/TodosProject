// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart'; // For Hive.initFlutter and adapter registration
import 'package:moriartytodos/ToDoFeatures/data/local_storage.dart';
import 'package:moriartytodos/ToDoFeatures/models/task_model.dart';
import 'package:moriartytodos/ToDoFeatures/pages/home_page.dart';
import 'package:moriartytodos/main.dart' as app; // To access locater and setupHive potentially

// Mock LocalStorage
class MockLocalStorage implements LocalStorage {
  List<TaskModel> _tasks = [];
  bool deleteTaskCalled = false;
  TaskModel? deletedTaskModel;

  void setInitialTasks(List<TaskModel> tasks) {
    _tasks = List.from(tasks);
    deleteTaskCalled = false;
    deletedTaskModel = null;
  }

  @override
  Future<void> addTask({required TaskModel taskModel}) async {
    _tasks.add(taskModel);
  }

  @override
  Future<bool> deleteTask({required TaskModel taskModel}) async {
    deleteTaskCalled = true;
    deletedTaskModel = taskModel;
    _tasks.removeWhere((task) => task.id == taskModel.id);
    return true;
  }

  @override
  Future<List<TaskModel>> getAllTask() async {
    // Simulate the sorting behavior of the original HiveLocalStorage
    _tasks.sort((TaskModel a, TaskModel b) => b.createdAt.compareTo(a.createdAt));
    return List.from(_tasks);
  }

  @override
  Future<TaskModel?> getTask({required String id}) async {
    return _tasks.firstWhere((task) => task.id == id, orElse: () => null);
  }

  @override
  Future<TaskModel> updateTask({required TaskModel taskModel}) async {
    final index = _tasks.indexWhere((task) => task.id == taskModel.id);
    if (index != -1) {
      _tasks[index] = taskModel;
    }
    return taskModel;
  }
}

// Helper function to pump ToDoMainScreen
Future<void> _pumpToDoMainScreen(WidgetTester tester, MockLocalStorage mockLocalStorage, {List<TaskModel> initialTasks = const []}) async {
  mockLocalStorage.setInitialTasks(initialTasks);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp( // MaterialApp is needed for Directionality, MediaQuery, etc.
        home: ToDoMainScreen(),
        // If using easy_localization, setup here or ensure it's handled
      ),
    ),
  );
  // Wait for tasks to be loaded and UI to settle from _getAllTaskFromDB
  await tester.pumpAndSettle();
}


void main() {
  late MockLocalStorage mockLocalStorage;

  // It's crucial to initialize Hive for tests if TaskModel extends HiveObject
  // and uses Hive features, or if the adapter needs to be registered.
  // For an in-memory version, Hive.init(null) can be used.
  // However, since we are fully mocking LocalStorage, direct Hive setup might be
  // less critical unless TaskModel itself cannot be instantiated without it.
  // Let's ensure the adapter is registered, as TaskModel uses @HiveType.
  setUpAll(() async {
    // Minimal Hive setup for TaskModelAdapter.
    // Using Hive.initFlutter('test') to avoid conflicts if any other test uses default Hive.
    // Or, if Hive is not strictly needed because we mock LocalStorage,
    // we might get away without it, but TaskModelAdapter registration is good.
    await Hive.initFlutter('test_moriarty_todos'); // Use a unique path for tests
    if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
  });

  setUp(() {
    app.locater.reset(); // Reset GetIt
    mockLocalStorage = MockLocalStorage();
    app.locater.registerSingleton<LocalStorage>(mockLocalStorage);
  });

  tearDownAll(() async {
    await Hive.close();
    // Consider deleting the test Hive box directory if Hive.initFlutter was used with a path
  });

  group('ToDoMainScreen Dismissible Tests', () {
    testWidgets('removes task from UI and calls deleteTask on swipe', (WidgetTester tester) async {
      final task1 = TaskModel.create(name: 'Task to swipe', createdAt: DateTime.now());
      final task2 = TaskModel.create(name: 'Another task', createdAt: DateTime.now().subtract(Duration(hours: 1)));
      
      await _pumpToDoMainScreen(tester, mockLocalStorage, initialTasks: [task1, task2]);

      expect(find.text('Task to swipe'), findsOneWidget);
      expect(find.text('Another task'), findsOneWidget);

      // Simulate a swipe
      await tester.drag(find.text('Task to swipe'), const Offset(-500.0, 0.0)); // Swipe left
      await tester.pumpAndSettle(); // Allow dismissal animation and state updates

      expect(find.text('Task to swipe'), findsNothing);
      expect(find.text('Another task'), findsOneWidget); // Ensure other task remains
      expect(mockLocalStorage.deleteTaskCalled, isTrue);
      expect(mockLocalStorage.deletedTaskModel?.id, task1.id);
    });
  });

  group('ToDoMainScreen Filtering Tests', () {
    final now = DateTime.now();
    final taskActive1 = TaskModel.create(name: 'Active Task 1', createdAt: now);
    final taskCompleted1 = TaskModel.create(name: 'Completed Task 1', createdAt: now.subtract(Duration(days:1)))..isCompleted = true;
    final taskActive2 = TaskModel.create(name: 'Active Task 2', createdAt: now.subtract(Duration(days:2)));
    
    final allFilterTasks = [taskActive1, taskCompleted1, taskActive2];

    testWidgets('filters for Active tasks', (WidgetTester tester) async {
      await _pumpToDoMainScreen(tester, mockLocalStorage, initialTasks: allFilterTasks);
      
      // Initially, all tasks should be visible (or sorted by date, check TaskItem content)
      expect(find.text('Active Task 1'), findsOneWidget);
      expect(find.text('Completed Task 1'), findsOneWidget);
      expect(find.text('Active Task 2'), findsOneWidget);

      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      expect(find.text('Active Task 1'), findsOneWidget);
      expect(find.text('Active Task 2'), findsOneWidget);
      expect(find.text('Completed Task 1'), findsNothing);
    });

    testWidgets('filters for Completed tasks', (WidgetTester tester) async {
      await _pumpToDoMainScreen(tester, mockLocalStorage, initialTasks: allFilterTasks);
      
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(find.text('Completed Task 1'), findsOneWidget);
      expect(find.text('Active Task 1'), findsNothing);
      expect(find.text('Active Task 2'), findsNothing);
    });

    testWidgets('shows All tasks after filtering for Completed', (WidgetTester tester) async {
      await _pumpToDoMainScreen(tester, mockLocalStorage, initialTasks: allFilterTasks);
      
      // Go to Completed
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Completed Task 1'), findsOneWidget);
      expect(find.text('Active Task 1'), findsNothing);

      // Go back to All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Active Task 1'), findsOneWidget);
      expect(find.text('Completed Task 1'), findsOneWidget);
      expect(find.text('Active Task 2'), findsOneWidget);
    });
     testWidgets('shows "empty_task_list" message when no tasks match filter', (WidgetTester tester) async {
      await _pumpToDoMainScreen(tester, mockLocalStorage, initialTasks: [taskActive1]); // Only one active task

      // Tap on "Completed" filter
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      // Verify active task is not shown
      expect(find.text('Active Task 1'), findsNothing);
      // Verify the placeholder message is shown
      // The actual text 'empty_task_list' will be translated if easy_localization is working in tests.
      // If not, we might need to find a key or a part of the translated string.
      // For now, assuming it might render the key if translations are not loaded in test.
      expect(find.text('empty_task_list'), findsOneWidget);
    });

    testWidgets('shows "empty_task_list" message when all tasks are empty initially', (WidgetTester tester) async {
      await _pumpToDoMainScreen(tester, mockLocalStorage, initialTasks: []);

      // Verify the placeholder message is shown
      expect(find.text('empty_task_list'), findsOneWidget);
      
      // Check that filter buttons are still there
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });
  });
}
