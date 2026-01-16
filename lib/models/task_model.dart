import 'package:hive/hive.dart';

part 'task_model.g.dart'; // This tells Hive where to generate code

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? note;

  @HiveField(2)
  DateTime? deadline;

  @HiveField(3)
  bool isCompleted;

  Task({
    required this.title,
    this.note,
    this.deadline,
    this.isCompleted = false,
  });
}
