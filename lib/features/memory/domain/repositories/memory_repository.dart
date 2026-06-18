import 'dart:typed_data';
import '../entities/memory.dart';

abstract class MemoryRepository {
  /// Saves a memory. Zero-knowledge encrypts files and text content on-device before sync.
  Future<void> saveMemory(Memory memory, Uint8List? fileData, String password);

  /// Retrieves list of memories (decrypting fields using the user's password).
  Future<List<Memory>> getMemories(String password);

  /// Retrieves a specific memory by ID.
  Future<Memory?> getMemoryById(String id, String password);

  /// Deletes a memory both locally and from Supabase.
  Future<void> deleteMemory(String id);

  /// Syncs cached local modifications with the Supabase database.
  Future<void> syncWithSupabase(String password);

  /// Performs an offline-first indexed or semantic search over user's memories.
  Future<List<Memory>> searchMemories(String query, String password);

  /// Evaluates and yields the Smart Memory Health Score (0-100).
  Future<int> calculateMemoryHealthScore(String password);

  /// Identifies duplicate items in the vault using hash comparisons and metadata.
  Future<List<Memory>> detectDuplicates(String password);

  /// Fetches context-aware associations between memory entries for graph visualizations.
  Future<List<Map<String, dynamic>>> getMemoryRelationships(String password);

  /// Persists a relationship link between two memories.
  Future<void> addRelationship(String sourceId, String targetId, String relationshipType);

  /// Processes the offline/background queue (OCR, encrypt, upload, categorize).
  Future<void> processBackgroundQueue(String password);
}
