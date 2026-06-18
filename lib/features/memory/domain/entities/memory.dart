class Memory {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? filePath;
  final String? fileUrl;
  final int? fileSize;
  final String? mimeType;
  final String sha256Hash;
  final String category;
  final int priorityScore;
  final List<String> tags;
  final String? ocrText;
  final String? aiSummary;
  final bool isProcessed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memory({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.filePath,
    this.fileUrl,
    this.fileSize,
    this.mimeType,
    required this.sha256Hash,
    required this.category,
    required this.priorityScore,
    required this.tags,
    this.ocrText,
    this.aiSummary,
    required this.isProcessed,
    required this.createdAt,
    required this.updatedAt,
  });

  Memory copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    String? sha256Hash,
    String? category,
    int? priorityScore,
    List<String>? tags,
    String? ocrText,
    String? aiSummary,
    bool? isProcessed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      category: category ?? this.category,
      priorityScore: priorityScore ?? this.priorityScore,
      tags: tags ?? this.tags,
      ocrText: ocrText ?? this.ocrText,
      aiSummary: aiSummary ?? this.aiSummary,
      isProcessed: isProcessed ?? this.isProcessed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
