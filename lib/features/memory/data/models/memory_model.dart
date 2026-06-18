import '../../domain/entities/memory.dart';

class MemoryModel extends Memory {
  MemoryModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.filePath,
    super.fileUrl,
    super.fileSize,
    super.mimeType,
    required super.sha256Hash,
    required super.category,
    required super.priorityScore,
    required super.tags,
    super.ocrText,
    super.aiSummary,
    required super.isProcessed,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      filePath: json['file_path'] as String?,
      fileUrl: json['file_url'] as String?,
      fileSize: json['file_size'] != null ? (json['file_size'] as num).toInt() : null,
      mimeType: json['mime_type'] as String?,
      sha256Hash: json['sha256_hash'] as String? ?? '',
      category: json['category'] as String,
      priorityScore: (json['priority_score'] as num? ?? 50).toInt(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      ocrText: json['ocr_text'] as String?,
      aiSummary: json['ai_summary'] as String?,
      isProcessed: json['is_processed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_size': fileSize,
      'mime_type': mimeType,
      'sha256_hash': sha256Hash,
      'category': category,
      'priority_score': priorityScore,
      'tags': tags,
      'ocr_text': ocrText,
      'ai_summary': aiSummary,
      'is_processed': isProcessed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MemoryModel.fromEntity(Memory entity) {
    return MemoryModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      filePath: entity.filePath,
      fileUrl: entity.fileUrl,
      fileSize: entity.fileSize,
      mimeType: entity.mimeType,
      sha256Hash: entity.sha256Hash,
      category: entity.category,
      priorityScore: entity.priorityScore,
      tags: entity.tags,
      ocrText: entity.ocrText,
      aiSummary: entity.aiSummary,
      isProcessed: entity.isProcessed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
