import 'package:flutter/material.dart';
import 'task_repository.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

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
              onPressed: () {
                setState(() {
                  TaskRepository.tasks.clear();
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
    int completedTasks = TaskRepository.tasks.where((task) => task.done).length;

    List<Task> filteredTasks = TaskRepository.tasks;
    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks
          .where((task) => task.done)
          .toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks
          .where((task) => !task.done)
          .toList();
    }

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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Masz dziś ${TaskRepository.tasks.length} zadania, wykonano: $completedTasks"),
            SizedBox(height: 16),
            Text("Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wszystkie";
                    });
                  },
                  child: Text("Wszystkie"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "do zrobienia";
                    });
                  },
                  child: Text("Do zrobienia"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wykonane";
                    });
                  },
                  child: Text("Wykonane"),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {

                  final task = filteredTasks[index];
                  return Dismissible(
                    key: ValueKey(task),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction){
                      setState(() {
                        TaskRepository.tasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Usunięto zadanie: ${task.title}"),
                        ),
                      );
                    },
                  child: TaskCard(
                      title: task.title,
                      subtitle: "termin: ${task.deadline} | priorytet: ${task.priority}",
                      done: task.done,

                      onChanged: (value){
                        setState((){
                          task.done = value!;
                        });
                      },
                      onTap: () async{
                        final Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );
                      if (updatedTask != null) {
                        setState(() {
                          TaskRepository.tasks[
                            TaskRepository.tasks.indexOf(task)
                          ] = updatedTask;
                        });
                        }
                       }
                      ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );

          if(newTask != null){
            setState((){
              TaskRepository.tasks.add(newTask);
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





