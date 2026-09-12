class TaskModel {
  final String id;
  final String weddingId;
  final String taskName;
  final String description;
  final double financialGoal;

  TaskModel({
    required this.id,
    required this.weddingId,
    required this.taskName,
    required this.description,
    required this.financialGoal,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      weddingId: map['wedding_id'] ?? '',
      taskName: map['task_name'] ?? '',
      description: map['description'] ?? '',
      financialGoal: (map['financial_goal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}