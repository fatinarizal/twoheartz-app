import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';


class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _dbService = SupabaseDatabaseService();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _goalController = TextEditingController();

  Future<void> _addTask() async {
    await _dbService.addTask(
      _nameController.text,
      _descController.text,
      double.tryParse(_goalController.text) ?? 0.00,
    );
    _nameController.clear();
    _descController.clear();
    _goalController.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Set New Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Task Name')),
                TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Task Description')),
                TextField(controller: _goalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Financial Goal (RM)')),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(onPressed: _addTask, child: const Text('Save Task')),
            ],
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _dbService.getTasksStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(task.taskName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${task.description}\nGoal: RM ${task.financialGoal}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}