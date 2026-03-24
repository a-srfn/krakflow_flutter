import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  List<Task> tasks = [
    Task(title: "Projekt Flutter", deadline: "jutro"),
    Task(title: "Ćwiczenia z matematyki", deadline: "dzisiaj"),
    Task(title: "Przeczytać o widgetach", deadline: "w tym tygodniu"),
    Task(title: "Przeczytać tekst o ludności rdzennej", deadline: "jutro")
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      home: Center(
        child: Column(
          children: [
            Text("tytuł"),
        Expanded(
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.deadline),
            );
          },
        ),
      ),
        ],
        ),
      ),
    );
  }
}
class Task{
  final String title;
  final String deadline;
  Task({required this.title, required this.deadline});
}
  class TaskCard extends StatelessWidget{
    final String title;
    final String subtitle;
    final IconData icon;

    const TaskCard({
      super.key,
      required this.title,
      required this.subtitle,
      required this.icon,
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




