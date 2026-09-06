enum ResourceType { 
  text, 
  pdf, 
  url, 
  link, // backward compatibility alias for url
  video, 
  note 
}

enum ResourceStatus { 
  pending,
  uploading, 
  processing, 
  extracting, 
  indexing, 
  synthesizing,
  processed,
  ready, 
  failed 
}

enum ResourceLabel { keep, useNow, reference, ignore }

class Resource {
  final String id;
  final String userId;
  final String title;
  final ResourceType type;
  final ResourceStatus status;
  final String? storagePath;
  final String? sourceUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Synthesis & UI Data (preserved for backwards compatibility)
  final ResourceLabel? mentorLabel;
  final String? content;
  final List<String> extractedConcepts;
  final List<String> usedByJourneyNodes;
  final String? generatedNotes;
  final String? synthesisMentorNote;
  final List<String> synthesisInputs; // ["Weakness: Calculus", "Goal: AI Engineer", etc.]

  // Getter alias for backwards compatibility
  String? get url => sourceUrl;

  Resource({
    required this.id,
    this.userId = '',
    required this.title,
    required this.type,
    required this.status,
    this.storagePath,
    String? sourceUrl,
    String? url,
    this.metadata = const {},
    this.mentorLabel,
    this.content,
    this.extractedConcepts = const [],
    this.usedByJourneyNodes = const [],
    this.generatedNotes,
    this.synthesisMentorNote,
    this.synthesisInputs = const [],
    required this.createdAt,
    DateTime? updatedAt,
  })  : sourceUrl = sourceUrl ?? url,
        updatedAt = updatedAt ?? createdAt;

  static ResourceType _parseType(dynamic value) {
    if (value == null) return ResourceType.note;
    final str = value.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'TEXT':
        return ResourceType.text;
      case 'PDF':
        return ResourceType.pdf;
      case 'URL':
        return ResourceType.url;
      case 'LINK':
        return ResourceType.link;
      case 'VIDEO':
        return ResourceType.video;
      case 'NOTE':
        return ResourceType.note;
      default:
        return ResourceType.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
          orElse: () => ResourceType.note,
        );
    }
  }

  static ResourceStatus _parseStatus(dynamic value) {
    if (value == null) return ResourceStatus.ready;
    final str = value.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'PENDING':
        return ResourceStatus.pending;
      case 'PROCESSED':
        return ResourceStatus.processed;
      case 'READY':
        return ResourceStatus.ready;
      case 'FAILED':
        return ResourceStatus.failed;
      case 'UPLOADING':
        return ResourceStatus.uploading;
      case 'PROCESSING':
        return ResourceStatus.processing;
      case 'EXTRACTING':
        return ResourceStatus.extracting;
      case 'INDEXING':
        return ResourceStatus.indexing;
      case 'SYNTHESIZING':
        return ResourceStatus.synthesizing;
      default:
        return ResourceStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
          orElse: () => ResourceStatus.ready,
        );
    }
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now();
    final updated = json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : created;

    return Resource(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? 'Untitled',
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      storagePath: json['storage_path'],
      sourceUrl: json['source_url'] ?? json['url'],
      metadata: json['metadata'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['metadata']) 
          : {},
      mentorLabel: json['mentor_label'] != null 
          ? ResourceLabel.values.firstWhere(
              (e) => e.name.toLowerCase() == json['mentor_label'].toString().toLowerCase(),
              orElse: () => ResourceLabel.reference,
            ) 
          : null,
      content: json['content'],
      extractedConcepts: List<String>.from(json['extracted_concepts'] ?? []),
      usedByJourneyNodes: List<String>.from(json['used_by_journey_nodes'] ?? []),
      generatedNotes: json['generated_notes'],
      synthesisMentorNote: json['synthesis_mentor_note'],
      synthesisInputs: List<String>.from(json['synthesis_inputs'] ?? []),
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'type': type == ResourceType.link ? 'URL' : type.name.toUpperCase(),
    'storage_path': storagePath,
    'source_url': sourceUrl,
    'status': status.name.toUpperCase(),
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    // UI / Legacy Compatibility
    'url': sourceUrl,
    'mentor_label': mentorLabel?.name,
    'content': content,
    'extracted_concepts': extractedConcepts,
    'used_by_journey_nodes': usedByJourneyNodes,
    'generated_notes': generatedNotes,
    'synthesis_mentor_note': synthesisMentorNote,
    'synthesis_inputs': synthesisInputs,
  };

  Resource copyWith({
    String? id,
    String? userId,
    String? title,
    ResourceType? type,
    ResourceStatus? status,
    String? storagePath,
    String? sourceUrl,
    Map<String, dynamic>? metadata,
    ResourceLabel? mentorLabel,
    String? url,
    String? content,
    List<String>? extractedConcepts,
    List<String>? usedByJourneyNodes,
    String? generatedNotes,
    String? synthesisMentorNote,
    List<String>? synthesisInputs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resource(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      storagePath: storagePath ?? this.storagePath,
      sourceUrl: sourceUrl ?? url ?? this.sourceUrl,
      metadata: metadata ?? this.metadata,
      mentorLabel: mentorLabel ?? this.mentorLabel,
      content: content ?? this.content,
      extractedConcepts: extractedConcepts ?? this.extractedConcepts,
      usedByJourneyNodes: usedByJourneyNodes ?? this.usedByJourneyNodes,
      generatedNotes: generatedNotes ?? this.generatedNotes,
      synthesisMentorNote: synthesisMentorNote ?? this.synthesisMentorNote,
      synthesisInputs: synthesisInputs ?? this.synthesisInputs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ResourceChunk {
  final String id;
  final String resourceId;
  final int chunkIndex;
  final String content;
  final Map<String, dynamic> metadata;
  final List<double>? embedding;
  final DateTime createdAt;

  ResourceChunk({
    required this.id,
    required this.resourceId,
    required this.chunkIndex,
    required this.content,
    this.metadata = const {},
    this.embedding,
    required this.createdAt,
  });

  factory ResourceChunk.fromJson(Map<String, dynamic> json) => ResourceChunk(
    id: json['id'] ?? '',
    resourceId: json['resource_id'] ?? '',
    chunkIndex: json['chunk_index'] ?? 0,
    content: json['content'] ?? '',
    metadata: json['metadata'] is Map<String, dynamic> 
        ? Map<String, dynamic>.from(json['metadata']) 
        : {},
    embedding: json['embedding'] != null 
        ? List<double>.from((json['embedding'] as List).map((e) => (e as num).toDouble())) 
        : null,
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'resource_id': resourceId,
    'chunk_index': chunkIndex,
    'content': content,
    'metadata': metadata,
    'embedding': embedding,
    'created_at': createdAt.toIso8601String(),
  };
}

class ResourceConcept {
  final String resourceId;
  final String conceptId;
  final double relevance;

  ResourceConcept({
    required this.resourceId,
    required this.conceptId,
    this.relevance = 1.0,
  });

  factory ResourceConcept.fromJson(Map<String, dynamic> json) => ResourceConcept(
    resourceId: json['resource_id'] ?? '',
    conceptId: json['concept_id'] ?? '',
    relevance: (json['relevance'] as num?)?.toDouble() ?? 1.0,
  );

  Map<String, dynamic> toJson() => {
    'resource_id': resourceId,
    'concept_id': conceptId,
    'relevance': relevance,
  };
}
