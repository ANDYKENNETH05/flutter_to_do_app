import 'package:flutter/material.dart';
import '../models/task_model.dart';

class AnimatedTaskTile extends StatelessWidget {
  final Task task;
  final Function(bool?)? onChanged;
  final VoidCallback onDelete;

  const AnimatedTaskTile({
    super.key,
    required this.task,
    this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey[300] : Colors.teal[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: task.deadline != null
            ? Text('Due: ${task.deadline!.toLocal()}'.split(' ')[0])
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
