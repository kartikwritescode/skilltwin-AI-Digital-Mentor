enum StepType { recall, learn, practice, prove, remediate, reflect, question, explanation }

class SessionStep {
  final String id;
  final String title;
  final String? instructions;
  final StepType type;
  final Map<String, dynamic> content;
  final bool isCompleted;

  SessionStep({
    required this.id,
    required this.title,
    this.instructions,
    required this.type,
    required this.content,
    this.isCompleted = false,
  });

  factory SessionStep.fromJson(Map<String, dynamic> json) => SessionStep(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        instructions: json['instructions'],
        type: StepType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => StepType.learn,
        ),
        content: json['content'] ?? {},
        isCompleted: json['is_completed'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instructions': instructions,
        'type': type.name,
        'content': content,
        'is_completed': isCompleted,
      };
}
