import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'landing_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
  }

  void _openAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: _AddTaskSheet(
            onAdd: (task) {
              _taskService.addTask(task);
              setState(() {}); // Refresh UI
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50], // soft pastel background
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        backgroundColor: Colors.teal[300],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingPage()),
            );
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet!\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              Task task = box.getAt(index)!;
              return _AnimatedTaskCard(
                task: task,
                onChanged: (val) {
                  setState(() {
                    task.isCompleted = val ?? false;
                    _taskService.updateTask(task);
                  });
                },
                onDelete: () {
                  _taskService.deleteTask(task);
                },
                index: index,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[300],
        onPressed: _openAddTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ---------------------- Animated Task Card ----------------------
class _AnimatedTaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?)? onChanged;
  final VoidCallback onDelete;
  final int index;

  const _AnimatedTaskCard({
    super.key,
    required this.task,
    this.onChanged,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 100),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.grey[300] : Colors.teal[100],
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
            activeColor: Colors.teal[300],
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
      ),
    );
  }
}

/// ---------------------- Add Task Sheet ----------------------
class _AddTaskSheet extends StatefulWidget {
  final Function(Task) onAdd;
  const _AddTaskSheet({required this.onAdd});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _deadline;

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _addTask() {
    if (_titleController.text.isEmpty) return;
    widget.onAdd(Task(
      title: _titleController.text,
      note: _noteController.text,
      deadline: _deadline,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(_deadline == null
                    ? 'No deadline chosen'
                    : 'Deadline: ${_deadline!.toLocal()}'.split(' ')[0]),
              ),
              TextButton(
                  onPressed: _pickDate, child: const Text('Pick Date')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[300],
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Task'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
