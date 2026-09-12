import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();

    return StreamBuilder<List<TaskModel>>(
      stream: dbService.getTasksStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final tasks = snapshot.data!;
        final double totalBudget = tasks.fold(0.0, (sum, item) => sum + item.financialGoal);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFFFCE4EC),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text('TOTAL BUDGETING SUM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
                      const SizedBox(height: 8),
                      Text('RM ${totalBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Summed dynamically from ${tasks.length} active tasks', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Task Budget Breakdown:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final item = tasks[index];
                    return ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.green),
                      title: Text(item.taskName),
                      subtitle: Text(item.description),
                      trailing: Text('RM ${item.financialGoal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}