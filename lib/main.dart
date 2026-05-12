import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'task_repository.dart';
import 'task_sync_service.dart';
import 'task_local_database.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("tasks");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
        );
  }
}

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>{

  String selectedFilter = "wszystkie";


  late Future<List<Task>> tasksFuture;
  @override
  void initState(){
    super.initState();
    tasksFuture = loadTasks();
  }
  Future<List<Task>> loadTasks() async {
      await TaskSyncService.loadInitialDataIfNeeded();
      return TaskLocalDatabase.getTasks();
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Potwierdzenie"),
          content: Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Anuluj"),
            ),
            TextButton(
            onPressed: () async {
            await TaskLocalDatabase.deleteAllTasks();
            setState(() {
              tasksFuture = loadTasks();
            });

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Usunięto wszystkie zadania"),
                ),
              );
            },
              child: Text("Usuń"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('KrakFlow'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteAllDialog,
          ),
        ],
      ),
        body: FutureBuilder<List<Task>>(
            future: tasksFuture,
            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("Błąd: ${snapshot.error}"),
                );
              }

              final tasks = snapshot.data ?? [];

              List<Task> filteredTasks = tasks;
              if (selectedFilter == "wykonane") {
                filteredTasks = tasks
                    .where((task) => task.done)
                    .toList();
              } else if (selectedFilter == "do zrobienia") {
                filteredTasks = tasks
                    .where((task) => !task.done)
                    .toList();
              }
              return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];

                    return Dismissible(
                      key: ValueKey(task),
                      direction: DismissDirection.endToStart,

                      onDismissed: (direction) async {

                        await TaskLocalDatabase
                            .deleteTask(task.id);

                        setState(() {
                          tasksFuture = loadTasks();
                        });

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "Usunięto zadanie: ${task.title}",
                            ),
                          ),
                        );
                      },
                      child: TaskCard(
                        title: task.title,
                        subtitle:
                        "termin: ${task.deadline} | priorytet: ${task.priority}",
                        done: task.done,
                        onChanged: (value) async {

                          final updatedTask = Task(
                            id: task.id,
                            title: task.title,
                            deadline: task.deadline,
                            priority: task.priority,
                            done: value ?? false,
                          );
                          await TaskLocalDatabase
                              .updateTask(updatedTask);
                          setState(() {
                            tasksFuture = loadTasks();
                          });
                        },
                        onTap: () async {

                          final Task? updatedTask =
                          await Navigator.push(
                              context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditTaskScreen(
                                    task: task,
                                  ),
                            ),
                          );

                          if (updatedTask != null) {

                            await TaskLocalDatabase
                                .updateTask(updatedTask);

                            setState(() {
                              tasksFuture = loadTasks();
                            });
                          }
                        },
                      ),
                    );
                  },
              );
            },
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          final Task? newTask =
          await Navigator.push(

            context,

            MaterialPageRoute(
              builder: (context) =>
                  AddTaskScreen(),
            ),
          );
          if (newTask != null) {

            await TaskLocalDatabase
                .addTask(newTask);

            setState(() {
              tasksFuture = loadTasks();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget{
   AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: "Tytuł zadania",
            border: OutlineInputBorder(),
          ),
        ),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  id: Random().nextInt(1000000),
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text,
                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}
class EditTaskScreen extends StatelessWidget {
  final Task task;

  EditTaskScreen({super.key, required this.task});

  late final TextEditingController titleController =
  TextEditingController(text: task.title);
  late final TextEditingController deadlineController =
  TextEditingController(text: task.deadline);
  late final TextEditingController priorityController =
  TextEditingController(text: task.priority);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Edytuj zadanie")),
      body: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Tytuł"),
          ),
          TextField(
            controller: deadlineController,
            decoration: InputDecoration(labelText: "Termin"),
          ),
          TextField(
            controller: priorityController,
            decoration: InputDecoration(labelText: "Priorytet"),
          ),
          ElevatedButton(
            onPressed: (){
              final updatedTask = Task(
                id: task.id,
                title: titleController.text,
                deadline: deadlineController.text,
                done: task.done,
                priority: priorityController.text,
              );

              Navigator.pop(context, updatedTask);
            },
            child: Text("Zapisz"),
          )
        ],
      ),
    );
  }
}





