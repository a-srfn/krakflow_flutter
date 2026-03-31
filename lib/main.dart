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
  @override
  Widget build(BuildContext context){
    int completedTasks = TaskRepository.tasks.where((task) => task.done).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('KrakFlow'),
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
            Expanded(
              child: ListView.builder(
                itemCount: TaskRepository.tasks.length,
                itemBuilder: (context, index) {
                  final task = TaskRepository.tasks[index];
                  return TaskCard(
                      title: task.title,
                      subtitle: "termin: ${task.deadline} | priorytet: ${task.priority}",
                      icon: task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                      priority: task.priority);
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
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(),
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
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: '',
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





