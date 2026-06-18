import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// On-device cryptographic service supporting Zero-Knowledge encryption.
/// Decrypts/encrypts files and metadata locally so the Supabase server only sees ciphertext.
class EncryptionHelper {
  /// Derives a 256-bit key from a password and salt using SHA-256 hashing.
  static encrypt.Key deriveKey(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  /// Encrypts plain text metadata (e.g. title, OCR, description) using AES-256-CBC.
  static String encryptText(String text, String password, {String salt = 'memora_meta_salt'}) {
    final key = deriveKey(password, salt);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: iv);
    
    // Store as IV_BASE64:CIPHERTEXT_BASE64
    return '${base64.encode(iv.bytes)}:${encrypted.base64}';
  }

  /// Decrypts AES-256-CBC encrypted metadata.
  static String decryptText(String combinedCipherText, String password, {String salt = 'memora_meta_salt'}) {
    try {
      final key = deriveKey(password, salt);
      final parts = combinedCipherText.split(':');
      if (parts.length != 2) throw Exception('Invalid ciphertext format');
      final iv = encrypt.IV(base64.decode(parts[0]));
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      throw Exception('Metadata decryption failed: invalid password or corrupted data');
    }
  }

  /// Encrypts raw binary file data using AES-256-CBC.
  static Uint8List encryptBytes(Uint8List data, String password, {String salt = 'memora_file_salt'}) {
    final key = deriveKey(password, salt);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    
    // Concatenate: [16 Bytes IV] + [Encrypted Data]
    final builder = BytesBuilder();
    builder.add(iv.bytes);
    builder.add(encrypted.bytes);
    return builder.toBytes();
  }

  /// Decrypts raw binary file data.
  static Uint8List decryptBytes(Uint8List encryptedData, String password, {String salt = 'memora_file_salt'}) {
    try {
      final key = deriveKey(password, salt);
      if (encryptedData.length < 16) throw Exception('Corrupted encrypted data');
      
      final ivBytes = encryptedData.sublist(0, 16);
      final cipherBytes = encryptedData.sublist(16);
      
      final iv = encrypt.IV(ivBytes);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(cipherBytes), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw Exception('File decryption failed: invalid password or corrupted file');
    }
  }

  /// Computes the SHA-256 hash of file data to enforce integrity.
  static String calculateSHA256(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }
}
