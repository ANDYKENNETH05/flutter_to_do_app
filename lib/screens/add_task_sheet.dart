import 'package:flutter/material.dart';
import '../models/task_model.dart';

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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12)),
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
