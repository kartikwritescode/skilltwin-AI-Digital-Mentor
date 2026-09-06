class MentorNotification {
  final String id;
  final String title;
  final String message;
  final String? conceptId;
  final String notificationType;
  final DateTime createdAt;
  final bool isRead;
  final String actionUrl;

  MentorNotification({
    required this.id,
    required this.title,
    required this.message,
    this.conceptId,
    this.notificationType = 'REVISION_DUE',
    required this.createdAt,
    this.isRead = false,
    this.actionUrl = '/revision',
  });

  String get timeAgoFormatted {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  MentorNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? conceptId,
    String? notificationType,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return MentorNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      conceptId: conceptId ?? this.conceptId,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  factory MentorNotification.fromJson(Map<String, dynamic> json) {
    return MentorNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Mentor Intervention',
      message: json['message'] ?? '',
      conceptId: json['concept_id']?.toString(),
      notificationType: json['notification_type'] ?? 'REVISION_DUE',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      actionUrl: json['action_url'] ?? '/revision',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'concept_id': conceptId,
        'notification_type': notificationType,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'action_url': actionUrl,
      };
}
