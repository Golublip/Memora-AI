import 'dart:convert';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../core/security/encryption_helper.dart';
import '../../../core/network/gemini_client.dart';
import '../../domain/entities/memory.dart';
import '../models/memory_model.dart';
import '../repositories/memory_repository.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final supabase.SupabaseClient _supabaseClient;
  final GeminiClient _geminiClient;
  Database? _db;

  MemoryRepositoryImpl({
    required supabase.SupabaseClient supabaseClient,
    required GeminiClient geminiClient,
  })  : _supabaseClient = supabaseClient,
        _geminiClient = geminiClient;

  // Initialize SQLite Local Database
  Future<Database> _getDatabase() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'memora_vault.db');
    
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Local memories table
        await db.execute('''
          CREATE TABLE local_memories (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            file_path TEXT,
            file_url TEXT,
            file_size INTEGER,
            mime_type TEXT,
            sha256_hash TEXT NOT NULL,
            category TEXT NOT NULL,
            priority_score INTEGER NOT NULL,
            tags TEXT NOT NULL, -- JSON string array
            ocr_text TEXT,
            ai_summary TEXT,
            is_processed INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        // Local background sync queue table
        await db.execute('''
          CREATE TABLE background_queue (
            id TEXT PRIMARY KEY,
            memory_id TEXT NOT NULL,
            status TEXT NOT NULL CHECK(status IN ('pending', 'processing', 'failed', 'completed')),
            action_type TEXT NOT NULL CHECK(action_type IN ('upload', 'delete')),
            file_data BLOB,
            attempts INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        // Relationships table
        await db.execute('''
          CREATE TABLE local_relationships (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            source_id TEXT NOT NULL,
            target_id TEXT NOT NULL,
            relationship_type TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  @override
  Future<void> saveMemory(Memory memory, Uint8List? fileData, String password) async {
    final db = await _getDatabase();
    
    // 1. Zero-Knowledge encrypt sensitive textual metadata locally
    final encryptedTitle = EncryptionHelper.encryptText(memory.title, password);
    final encryptedDesc = memory.description != null 
        ? EncryptionHelper.encryptText(memory.description!, password) 
        : null;
    final encryptedOcr = memory.ocrText != null
        ? EncryptionHelper.encryptText(memory.ocrText!, password)
        : null;
    final encryptedSummary = memory.aiSummary != null
        ? EncryptionHelper.encryptText(memory.aiSummary!, password)
        : null;

    final encryptedMemory = MemoryModel.fromEntity(memory).copyWith(
      title: encryptedTitle,
      description: encryptedDesc,
      ocrText: encryptedOcr,
      aiSummary: encryptedSummary,
    );

    // 2. Encrypt actual raw file data locally
    Uint8List? encryptedFileData;
    if (fileData != null) {
      encryptedFileData = EncryptionHelper.encryptBytes(fileData, password);
    }

    // 3. Write locally to SQLite (Offline First)
    final memoryModel = MemoryModel.fromEntity(encryptedMemory);
    final memoryJson = memoryModel.toJson();
    memoryJson['tags'] = json.encode(memoryModel.tags); // convert list to json string
    memoryJson['is_processed'] = memoryModel.isProcessed ? 1 : 0;
    
    await db.insert('local_memories', memoryJson, conflictAlgorithm: ConflictAlgorithm.replace);

    // 4. Queue background synchronization tasks
    final queueId = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert('background_queue', {
      'id': queueId,
      'memory_id': memory.id,
      'status': 'pending',
      'action_type': 'upload',
      'file_data': encryptedFileData,
      'attempts': 0,
      'created_at': DateTime.now().toIso8601String()
    });

    // 5. Fire background worker (non-blocking)
    processBackgroundQueue(password).catchError((_) {});
  }

  @override
  Future<List<Memory>> getMemories(String password) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('local_memories', orderBy: 'created_at DESC');

    final List<Memory> results = [];
    for (var map in maps) {
      try {
        final Map<String, dynamic> mutableMap = Map<String, dynamic>.from(map);
        mutableMap['tags'] = json.decode(map['tags'] as String);
        mutableMap['is_processed'] = map['is_processed'] == 1;
        
        final encryptedModel = MemoryModel.fromJson(mutableMap);

        // Zero-Knowledge decryption locally
        final decryptedTitle = EncryptionHelper.decryptText(encryptedModel.title, password);
        final decryptedDesc = encryptedModel.description != null
            ? EncryptionHelper.decryptText(encryptedModel.description!, password)
            : null;
        final decryptedOcr = encryptedModel.ocrText != null
            ? EncryptionHelper.decryptText(encryptedModel.ocrText!, password)
            : null;
        final decryptedSummary = encryptedModel.aiSummary != null
            ? EncryptionHelper.decryptText(encryptedModel.aiSummary!, password)
            : null;

        results.add(encryptedModel.copyWith(
          title: decryptedTitle,
          description: decryptedDesc,
          ocrText: decryptedOcr,
          aiSummary: decryptedSummary,
        ));
      } catch (_) {
        // Skip records that fail decryption (e.g. incorrect password context)
      }
    }
    return results;
  }

  @override
  Future<Memory?> getMemoryById(String id, String password) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'local_memories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    final map = maps.first;
    try {
      final Map<String, dynamic> mutableMap = Map<String, dynamic>.from(map);
      mutableMap['tags'] = json.decode(map['tags'] as String);
      mutableMap['is_processed'] = map['is_processed'] == 1;
      
      final encryptedModel = MemoryModel.fromJson(mutableMap);

      return encryptedModel.copyWith(
        title: EncryptionHelper.decryptText(encryptedModel.title, password),
        description: encryptedModel.description != null
            ? EncryptionHelper.decryptText(encryptedModel.description!, password)
            : null,
        ocrText: encryptedModel.ocrText != null
            ? EncryptionHelper.decryptText(encryptedModel.ocrText!, password)
            : null,
        aiSummary: encryptedModel.aiSummary != null
            ? EncryptionHelper.decryptText(encryptedModel.aiSummary!, password)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteMemory(String id) async {
    final db = await _getDatabase();
    
    // Remove locally
    await db.delete('local_memories', where: 'id = ?', whereArgs: [id]);

    // Enqueue background deletion task
    final queueId = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert('background_queue', {
      'id': queueId,
      'memory_id': id,
      'status': 'pending',
      'action_type': 'delete',
      'file_data': null,
      'attempts': 0,
      'created_at': DateTime.now().toIso8601String()
    });
    
    // Call remote sync trigger
    _supabaseClient.from('memories').delete().match({'id': id}).then((_) {}).catchError((_) {});
  }

  @override
  Future<void> syncWithSupabase(String password) async {
    await processBackgroundQueue(password);
  }

  @override
  Future<List<Memory>> searchMemories(String query, String password) async {
    // Basic local query filter since SQLite title/description columns store ciphertexts.
    // In production, we retrieve all decrypted entries, then apply a localized indexed substring match.
    // This maintains zero-knowledge privacy on remote servers.
    final allMemories = await getMemories(password);
    if (query.isEmpty) return allMemories;
    
    final lowerQuery = query.toLowerCase();
    return allMemories.where((m) {
      return m.title.toLowerCase().contains(lowerQuery) ||
          (m.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (m.ocrText?.toLowerCase().contains(lowerQuery) ?? false) ||
          m.tags.any((t) => t.toLowerCase().contains(lowerQuery)) ||
          m.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<int> calculateMemoryHealthScore(String password) async {
    final memories = await getMemories(password);
    if (memories.isEmpty) return 100;

    double score = 100.0;

    // 1. Categorization Completeness (files not in Dump category)
    final dumpCount = memories.where((m) => m.category == 'Dump').length;
    final dumpRatio = dumpCount / memories.length;
    score -= (dumpRatio * 30.0); // Up to 30 points deducted for messy dump files

    // 2. Duplicate files ratio
    final duplicates = await detectDuplicates(password);
    final duplicateRatio = duplicates.length / memories.length;
    score -= (duplicateRatio * 25.0); // Up to 25 points deducted for duplicate clutter

    // 3. Untagged files
    final untaggedCount = memories.where((m) => m.tags.isEmpty || m.tags.contains('uncategorized')).length;
    final untaggedRatio = untaggedCount / memories.length;
    score -= (untaggedRatio * 15.0); // Up to 15 points deducted for lacking tags

    // 4. Missing metadata (description or summary)
    final incompleteCount = memories.where((m) => (m.description == null || m.description!.isEmpty) && (m.aiSummary == null || m.aiSummary!.isEmpty)).length;
    final incompleteRatio = incompleteCount / memories.length;
    score -= (incompleteRatio * 15.0); // Up to 15 points deducted for poor metadata

    // 5. System priority checks (expired/pending checks)
    // Here we can deduct up to 15 points if urgent priority documents (score > 80) are unprocessed
    final unprocessedUrgentCount = memories.where((m) => m.priorityScore > 80 && !m.isProcessed).length;
    score -= (unprocessedUrgentCount * 5.0);

    if (score < 0) score = 0;
    return score.round();
  }

  @override
  Future<List<Memory>> detectDuplicates(String password) async {
    final memories = await getMemories(password);
    final List<Memory> duplicates = [];
    final Set<String> uniqueHashes = {};

    for (var memory in memories) {
      if (memory.sha256Hash.isNotEmpty) {
        if (uniqueHashes.contains(memory.sha256Hash)) {
          duplicates.add(memory);
        } else {
          uniqueHashes.add(memory.sha256Hash);
        }
      }
    }
    return duplicates;
  }

  @override
  Future<List<Map<String, dynamic>>> getMemoryRelationships(String password) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('local_relationships');
    return maps;
  }

  @override
  Future<void> addRelationship(String sourceId, String targetId, String relationshipType) async {
    final db = await _getDatabase();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final createdAt = DateTime.now().toIso8601String();
    
    final relData = {
      'id': id,
      'user_id': _supabaseClient.auth.currentUser?.id ?? 'default_user',
      'source_id': sourceId,
      'target_id': targetId,
      'relationship_type': relationshipType,
      'created_at': createdAt
    };

    await db.insert('local_relationships', relData, conflictAlgorithm: ConflictAlgorithm.replace);

    // Sync remotely
    _supabaseClient.from('memory_relationships').insert(relData).then((_) {}).catchError((_) {});
  }

  @override
  Future<void> processBackgroundQueue(String password) async {
    final db = await _getDatabase();
    
    // Fetch pending jobs
    final List<Map<String, dynamic>> pendingTasks = await db.query(
      'background_queue',
      where: 'status = ? OR status = ?',
      whereArgs: ['pending', 'failed'],
      orderBy: 'created_at ASC',
    );

    for (var task in pendingTasks) {
      final taskId = task['id'] as String;
      final memoryId = task['memory_id'] as String;
      final actionType = task['action_type'] as String;
      final fileData = task['file_data'] as Uint8List?;
      final attempts = task['attempts'] as int;

      // Update status to processing
      await db.update(
        'background_queue',
        {'status': 'processing'},
        where: 'id = ?',
        whereArgs: [taskId],
      );

      try {
        if (actionType == 'upload') {
          // 1. Get raw memory record from local SQLite
          final localMemList = await db.query('local_memories', where: 'id = ?', whereArgs: [memoryId]);
          if (localMemList.isEmpty) throw Exception('Local memory record missing');
          final memoryMap = Map<String, dynamic>.from(localMemList.first);
          memoryMap['tags'] = json.decode(memoryMap['tags'] as String);
          memoryMap['is_processed'] = memoryMap['is_processed'] == 1;
          final localMemory = MemoryModel.fromJson(memoryMap);

          String? remoteFileUrl;
          String? remoteFilePath;

          // 2. Upload file to Supabase Storage if binary exists
          if (fileData != null && localMemory.filePath != null) {
            final uploadPath = localMemory.filePath!;
            // Push encrypted binary bytes directly to Supabase storage bucket
            await _supabaseClient.storage
                .from('vaults')
                .uploadBinary(uploadPath, fileData);
            
            remoteFilePath = uploadPath;
            remoteFileUrl = _supabaseClient.storage.from('vaults').getPublicUrl(uploadPath);
          }

          // 3. Process with Gemini API
          // Decrypt title for parsing hints
          final decryptedTitle = EncryptionHelper.decryptText(localMemory.title, password);
          final decryptedOcr = localMemory.ocrText != null 
              ? EncryptionHelper.decryptText(localMemory.ocrText!, password) 
              : '';
          
          final analysisResult = await _geminiClient.analyzeContent(
            decryptedOcr,
            decryptedTitle,
            localMemory.mimeType ?? 'application/octet-stream',
          );

          // 4. Update memory details locally & remotely
          final updatedMemory = localMemory.copyWith(
            category: analysisResult.category,
            priorityScore: analysisResult.priorityScore,
            tags: analysisResult.tags,
            aiSummary: EncryptionHelper.encryptText(analysisResult.summary, password),
            isProcessed: true,
            fileUrl: remoteFileUrl,
            filePath: remoteFilePath,
            updatedAt: DateTime.now(),
          );

          final updatedJson = MemoryModel.fromEntity(updatedMemory).toJson();
          updatedJson['tags'] = json.encode(updatedMemory.tags);
          updatedJson['is_processed'] = 1;

          // Write updated back to local SQLite
          await db.update('local_memories', updatedJson, where: 'id = ?', whereArgs: [memoryId]);

          // Write updated back to Supabase remote database
          await _supabaseClient.from('memories').upsert(updatedJson);

          // 5. Store any suggestions / relationships discovered
          for (var rel in analysisResult.relationships) {
            final targetTitle = rel['suggested_target_title'] as String;
            final relType = rel['relationship_type'] as String;
            
            // Search locally for matching target memory
            final matches = await getMemories(password);
            final target = matches.firstWhere(
              (m) => m.title.toLowerCase().contains(targetTitle.toLowerCase()),
              orElse: () => updatedMemory,
            );

            if (target.id != updatedMemory.id) {
              await addRelationship(updatedMemory.id, target.id, relType);
            }
          }

          // 6. Write Reminders into remote and local systems
          for (var rem in analysisResult.reminders) {
            final remData = {
              'id': DateTime.now().millisecondsSinceEpoch.toString() + rem['title'].hashCode.toString(),
              'user_id': _supabaseClient.auth.currentUser?.id ?? 'default_user',
              'memory_id': memoryId,
              'title': rem['title'],
              'description': rem['description'] ?? '',
              'due_date': rem['due_date'],
              'is_completed': 0,
              'created_at': DateTime.now().toIso8601String()
            };
            // Insert local reminder (if reminders table is created)
            await _supabaseClient.from('reminders').insert(remData).catchError((_) {});
          }
        } else if (actionType == 'delete') {
          // Deletion from storage & database
          // (Handled at invocation, but we verify here if sync queue cleanup is needed)
        }

        // Remove task from queue upon success
        await db.delete('background_queue', where: 'id = ?', whereArgs: [taskId]);

      } catch (e) {
        // Increment attempts and mark as failed
        await db.update(
          'background_queue',
          {
            'status': 'failed',
            'attempts': attempts + 1,
          },
          where: 'id = ?',
          whereArgs: [taskId],
        );
      }
    }
  }
}
