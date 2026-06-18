import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Output details derived from Gemini Analysis.
class AICategorizationResult {
  final String category;
  final int priorityScore;
  final List<String> tags;
  final String summary;
  final List<Map<String, dynamic>> relationships;
  final List<Map<String, dynamic>> reminders;

  AICategorizationResult({
    required this.category,
    required this.priorityScore,
    required this.tags,
    required this.summary,
    required this.relationships,
    required this.reminders,
  });

  factory AICategorizationResult.fromJson(Map<String, dynamic> json) {
    return AICategorizationResult(
      category: json['category'] ?? 'Dump',
      priorityScore: json['priority_score'] ?? 50,
      tags: List<String>.from(json['tags'] ?? []),
      summary: json['summary'] ?? '',
      relationships: List<Map<String, dynamic>>.from(json['relationships'] ?? []),
      reminders: List<Map<String, dynamic>>.from(json['reminders'] ?? []),
    );
  }

  factory AICategorizationResult.fallback() {
    return AICategorizationResult(
      category: 'Dump',
      priorityScore: 30,
      tags: ['uncategorized'],
      summary: 'Manual processing required.',
      relationships: [],
      reminders: [],
    );
  }
}

class GeminiClient {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiClient({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Categorizes OCR contents, tags the file, computes importance, and flags deadlines.
  Future<AICategorizationResult> analyzeContent(String ocrText, String fileName, String mimeType) async {
    final prompt = '''
You are the intelligence engine of Memora AI, a personal second brain.
Analyze the following extracted file text and metadata to classify it.

File Name: $fileName
Mime Type: $mimeType
OCR Extracted Text:
"$ocrText"

Classify this file into exactly one category: 'Education', 'Career', 'Health', 'Finance', 'Personal', 'Important Documents', 'Saved Links', or 'AI Generated'.
Assign an importance priority_score (0 to 100) based on urgency and permanence (e.g. certificates, IDs, receipts are high; random screenshots are low).
Extract relevant tags, summarize in 1-2 sentences, discover prospective connection relationships to other topics (e.g., matching a certificate to an internship or resume), and identify any due dates, expirations, or renewal dates that warrant auto-generating a calendar reminder.

Return ONLY a raw JSON object matching this schema. Do not enclose it in markdown block tags:
{
  "category": "Education",
  "priority_score": 85,
  "tags": ["coursera", "analytics", "certificate"],
  "summary": "Google Data Analytics Professional Certificate completed on Coursera.",
  "relationships": [
    {
      "suggested_target_title": "Resume",
      "relationship_type": "referenced_in"
    }
  ],
  "reminders": [
    {
      "title": "Renew Analytics Credentials",
      "due_date": "2027-06-18T10:00:00Z",
      "description": "Certificate renewal due in 1 year."
    }
  ]
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';
      
      // Clean up optional json tags if gemini wrapped it
      String cleanedText = responseText;
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();
      
      final Map<String, dynamic> data = json.decode(cleanedText);
      return AICategorizationResult.fromJson(data);
    } catch (e) {
      // Fallback on parsing error or API blockage
      return AICategorizationResult.fallback();
    }
  }

  /// Interactive Q&A chat where the user queries their memory database context.
  Future<String> chatWithMemories(String userQuestion, List<Map<String, dynamic>> memoriesContext) async {
    final contextBuffer = StringBuffer();
    for (var memory in memoriesContext) {
      contextBuffer.writeln('- Memory ID: ${memory['id']}');
      contextBuffer.writeln('  Title: ${memory['title']}');
      contextBuffer.writeln('  Category: ${memory['category']}');
      contextBuffer.writeln('  Priority Score: ${memory['priority_score']}');
      contextBuffer.writeln('  Tags: ${(memory['tags'] as List).join(', ')}');
      if (memory['ocr_text'] != null && memory['ocr_text'].toString().isNotEmpty) {
        contextBuffer.writeln('  OCR Extracted Text: ${memory['ocr_text']}');
      }
      if (memory['ai_summary'] != null && memory['ai_summary'].toString().isNotEmpty) {
        contextBuffer.writeln('  Summary: ${memory['ai_summary']}');
      }
      contextBuffer.writeln('');
    }

    final prompt = '''
You are Memora AI, the user's second brain. You possess full contextual knowledge of their personal vault.
Answer the user's question accurately using only the memories context below. 

User Memories Context:
${contextBuffer.toString()}

User Question: "$userQuestion"

Reply in a clear, friendly, and helpful tone. Provide specific dates, file names, or summary contents if found. If the answer cannot be inferred from the context, politely state so.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No memory record found to answer that.';
    } catch (e) {
      return 'Second Brain Chat is currently offline. Error: ${e.toString()}';
    }
  }
}
