import'package:flutter/material.dart';
class TaskRepository {
  static List<Task> tasks = [
    Task(
        title: "Wysłać zadanie",
        deadline: "do północy",
        done: true,
        priority: "wysoki"),
    Task(
        title: "Odebrać paczkę",
        deadline: "piątek",
        done: false,
        priority: "niski"),
    Task(
        title: "Nauka do kolokwium",
        deadline: "poniedziałek",
        done: false,
        priority: "średni"),
    Task(
        title: "Przeczytać tekst o ludności rdzennej",
        deadline: "jutro",
        done: false,
        priority: "wysoki")
  ];
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