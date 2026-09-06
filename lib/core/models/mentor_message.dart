enum MentorIntent { inform, recommend, remediate, clarify, reflect }

enum MessageSender { mentor, user }

enum MentorAction { 
  learn, 
  revise, 
  practice, 
  prove, 
  teach, 
  remediate, 
  skip, 
  reflect 
}

class MentorThread {
  final String id;
  final String userId;
  final String? goalId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  MentorThread({
    required this.id,
    required this.userId,
    this.goalId,
    this.title,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  factory MentorThread.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now();
    return MentorThread(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      goalId: json['goal_id'],
      title: json['title'],
      createdAt: created,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : created,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'goal_id': goalId,
    'title': title,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  MentorThread copyWith({
    String? id,
    String? userId,
    String? goalId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MentorThread(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MentorMessage {
  final String id;
  final String threadId;
  final String userId;
  final String role;
  final String text; // Schema: content
  final MessageSender sender;
  final MentorIntent? intent;
  final DateTime timestamp; // Schema: created_at
  final Map<String, dynamic> metadata;
  
  // Structured action fields
  final String? ctaText;
  final MentorAction? actionType;
  final Map<String, dynamic>? actionData;
  final String? whyContext;
  
  // Concept context
  final String? conceptId;
  final String? conceptTitle;

  String get content => text;
  DateTime get createdAt => timestamp;

  MentorMessage({
    required this.id,
    this.threadId = '',
    this.userId = '',
    String? role,
    required this.text,
    MessageSender? sender,
    this.intent,
    required this.timestamp,
    this.metadata = const {},
    this.ctaText,
    this.actionType,
    this.actionData,
    this.whyContext,
    this.conceptId,
    this.conceptTitle,
  })  : sender = sender ?? ((role?.toLowerCase() == 'user') ? MessageSender.user : MessageSender.mentor),
        role = role ?? ((sender == MessageSender.user) ? 'user' : 'assistant');

  static MessageSender _parseSender(dynamic value) {
    if (value == null) return MessageSender.mentor;
    final str = value.toString().toLowerCase();
    if (str == 'user') return MessageSender.user;
    return MessageSender.mentor;
  }

  factory MentorMessage.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['sender'] ?? json['role'];
    final parsedSender = _parseSender(senderRaw);
    final rawRole = (json['role'] ?? (parsedSender == MessageSender.user ? 'user' : 'assistant')).toString();
    final contentText = (json['content'] ?? json['text'] ?? '').toString();
    final created = json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : (json['timestamp'] != null 
            ? DateTime.parse(json['timestamp']) 
            : DateTime.now());

    final meta = json['metadata'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['metadata'])
        : <String, dynamic>{};

    return MentorMessage(
      id: json['id'] ?? '',
      threadId: json['thread_id'] ?? meta['thread_id'] ?? '',
      userId: json['user_id'] ?? meta['user_id'] ?? '',
      role: rawRole,
      text: contentText,
      sender: parsedSender,
      intent: json['intent'] != null 
        ? MentorIntent.values.firstWhere((e) => e.name == json['intent'], orElse: () => MentorIntent.inform) 
        : null,
      timestamp: created,
      metadata: meta,
      ctaText: json['cta_text'] ?? meta['cta_text'],
      actionType: json['action_type'] != null 
        ? MentorAction.values.firstWhere((e) => e.name.toLowerCase() == json['action_type'].toString().toLowerCase(), orElse: () => MentorAction.learn) 
        : null,
      actionData: json['action_data'] ?? (meta['action_data'] is Map<String, dynamic> ? meta['action_data'] : null),
      whyContext: json['why_context'] ?? meta['why_context'],
      conceptId: json['concept_id'] ?? meta['concept_id'],
      conceptTitle: json['concept_title'] ?? meta['concept_title'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'thread_id': threadId,
    'user_id': userId,
    'role': role,
    'content': text,
    'metadata': {
      ...metadata,
      if (ctaText != null) 'cta_text': ctaText,
      if (actionType != null) 'action_type': actionType?.name,
      if (actionData != null) 'action_data': actionData,
      if (whyContext != null) 'why_context': whyContext,
      if (conceptId != null) 'concept_id': conceptId,
      if (conceptTitle != null) 'concept_title': conceptTitle,
    },
    'created_at': timestamp.toIso8601String(),
    // Legacy fields for backward compatibility
    'text': text,
    'sender': sender.name,
    'intent': intent?.name,
    'timestamp': timestamp.toIso8601String(),
    'cta_text': ctaText,
    'action_type': actionType?.name,
    'action_data': actionData,
    'why_context': whyContext,
    'concept_id': conceptId,
    'concept_title': conceptTitle,
  };
}
