class User {
  final String id;
  final String email;
  final String name;
  final String displayName;
  final String timezone;
  final int dailyMinutes;
  final Map<String, dynamic> preferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    String? name,
    String? displayName,
    this.timezone = 'Asia/Kolkata',
    this.dailyMinutes = 30,
    this.preferences = const {},
    this.createdAt,
    this.updatedAt,
  })  : name = name ?? displayName ?? '',
        displayName = displayName ?? name ?? '';

  factory User.fromJson(Map<String, dynamic> json) {
    final rawName = json['full_name'] ?? json['display_name'] ?? json['name'] ?? '';
    final prefs = json['preferences'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['preferences'])
        : <String, dynamic>{};
    final daily = (json['daily_minutes'] as num?)?.toInt() ?? 
        (prefs['daily_minutes'] as num?)?.toInt() ?? 30;
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: rawName.toString(),
      displayName: rawName.toString(),
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      dailyMinutes: daily,
      preferences: prefs,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'full_name': name,
        'display_name': displayName,
        'timezone': timezone,
        'daily_minutes': dailyMinutes,
        'preferences': {
          ...preferences,
          'daily_minutes': dailyMinutes,
        },
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? displayName,
    String? timezone,
    int? dailyMinutes,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      timezone: timezone ?? this.timezone,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

