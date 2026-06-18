import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/security/encryption_helper.dart';
import '../../lib/features/memory/domain/entities/memory.dart';

void main() {
  group('Zero-Knowledge Encryption Tests', () {
    const password = 'test_secure_password';
    const originalText = 'Highly confidential PAN card ID: ABCDE1234F';

    test('Text Encryption and Decryption matches original string', () {
      final encrypted = EncryptionHelper.encryptText(originalText, password);
      expect(encrypted, isNot(equals(originalText)));
      expect(encrypted.contains(':'), isTrue);

      final decrypted = EncryptionHelper.decryptText(encrypted, password);
      expect(decrypted, equals(originalText));
    });

    test('Decryption with wrong password fails throws Exception', () {
      final encrypted = EncryptionHelper.encryptText(originalText, password);
      expect(
        () => EncryptionHelper.decryptText(encrypted, 'wrong_password'),
        throwsA(isA<Exception>()),
      );
    });

    test('Binary Byte Encryption and Decryption matches original bytes', () {
      final rawBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
      final encryptedBytes = EncryptionHelper.encryptBytes(rawBytes, password);
      
      expect(encryptedBytes.length, greaterThan(16)); // IV (16) + cipher block
      
      final decryptedBytes = EncryptionHelper.decryptBytes(encryptedBytes, password);
      expect(decryptedBytes, equals(rawBytes));
    });

    test('File Integrity Checksum SHA-256 remains constant', () {
      final rawBytes = Uint8List.fromList(utf8.encode('Memora AI Second Brain'));
      final hash1 = EncryptionHelper.calculateSHA256(rawBytes);
      final hash2 = EncryptionHelper.calculateSHA256(rawBytes);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // standard SHA-256 hex length
    });
  });

  group('Memory Health Score Formula Tests', () {
    test('Empty Memory List returns a perfect 100 score', () {
      final score = calculateHealthMock(List.empty(), List.empty());
      expect(score, equals(100));
    });

    test('Unsorted dump files deduct from health score', () {
      final memories = [
        createMockMemory(category: 'Dump'),
        createMockMemory(category: 'Education'),
      ];
      final score = calculateHealthMock(memories, []);
      // 30% of files in dump = (0.5 * 30) = 15 points deduction
      expect(score, equals(85));
    });

    test('Duplicate files deduct from health score', () {
      final memories = [
        createMockMemory(category: 'Education', hash: 'hash1'),
        createMockMemory(category: 'Career', hash: 'hash1'), // duplicate hash
      ];
      final duplicates = [memories[1]];
      final score = calculateHealthMock(memories, duplicates);
      // Deducts 25 points based on 50% duplicate ratio
      expect(score, equals(88)); // 100 - (0.5 * 25) = 87.5 => 88
    });
  });
}

// Mock test helpers
Memory createMockMemory({required String category, String hash = ''}) {
  return Memory(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: 'user123',
    title: 'Test Node',
    sha256Hash: hash,
    category: category,
    priorityScore: 60,
    tags: ['test'],
    isProcessed: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

int calculateHealthMock(List<Memory> memories, List<Memory> duplicates) {
  if (memories.isEmpty) return 100;
  double score = 100.0;

  // 1. Categorization Completeness
  final dumpCount = memories.where((m) => m.category == 'Dump').length;
  final dumpRatio = dumpCount / memories.length;
  score -= (dumpRatio * 30.0);

  // 2. Duplicate files ratio
  final duplicateRatio = duplicates.length / memories.length;
  score -= (duplicateRatio * 25.0);

  if (score < 0) score = 0;
  return score.round();
}
