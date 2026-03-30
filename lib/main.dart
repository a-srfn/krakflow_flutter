import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  List<Task> tasks = [
    Task(title: "Wysłać zadanie", deadline: "do północy", done: true, priority: "wysoki"),
    Task(title: "Odebrać paczkę", deadline: "piątek", done: false, priority: "niski"),
    Task(title: "Nauka do kolokwium", deadline: "poniedziałek", done: false, priority: "średni"),
    Task(title: "Przeczytać tekst o ludności rdzennej", deadline: "jutro", done: false, priority: "wysoki")
  ];

  @override
  Widget build(BuildContext context) {
    int completedTasks = tasks.where((task) => task.done).length;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
        title: Text('KrakFlow'),
        ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masz dziś ${tasks.length} zadania, wykonano: ${completedTasks}"),
              SizedBox(height: 16),
              Text("Dzisiejsze zadania",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )
              ),
          Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
             final task = tasks[index];
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
        ),
        );
  }
}
class Task{
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({required this.title, required this.deadline, required this.done, required this.priority});
}
  class TaskCard extends StatelessWidget{
    final String title;
    final String subtitle;
    final IconData icon;
    final String priority;

    const TaskCard({
      super.key,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.priority
  });
    @override
    Widget build(BuildContext context){
      return Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      );
    }
  }




