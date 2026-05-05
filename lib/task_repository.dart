import 'package:flutter/material.dart';
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
  bool done;
  final String priority;
  Task({required this.title, required this.deadline, required this.done, required this.priority});
}
class TaskCard extends StatelessWidget{
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onTap,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context){
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
            title,
        style: TextStyle(
          decoration: done
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: done ? Colors.grey : Colors.black,
        )),
        subtitle: Text(subtitle),
      ),
    );
  }
}