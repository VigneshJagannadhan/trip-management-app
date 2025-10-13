import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    // Replace with your Supabase project URL and anon key
    String supabaseUrl = dotenv.env['SUPA_BASE_URL'] ?? "";
    String supabaseAnonKey = dotenv.env['SUPA_BASE_ANON_KEY'] ?? "";

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }

  /// Upload image to Supabase Storage
  static Future<String?> uploadImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final fileBytes = await File(filePath).readAsBytes();
      final fileExt = fileName.split('.').last;
      final newFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final response = await client.storage
          .from('trip-images')
          .uploadBinary(newFileName, fileBytes);

      if (response.isNotEmpty) {
        final imageUrl = client.storage
            .from('trip-images')
            .getPublicUrl(newFileName);
        return imageUrl;
      }
      return null;
    } catch (e) {
      log('Error uploading image to Supabase: $e');
      return null;
    }
  }
}
