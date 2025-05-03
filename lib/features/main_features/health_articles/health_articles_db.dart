import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class HealthArticlesDB {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  /// Fetches all published health articles, including author details.
  Future<List<Map<String, dynamic>>> getAllArticles() async {
    try {
      // Fetch articles and join with doctors table to get author name
      final response = await _supabase
          .from('health_articles')
          .select('''
            article_id,
            title,
            content,
            created_at,
            updated_at,
            author:doctor_id (
              id,
              title,
              first_name,
              last_name
            )
          ''')
          .order('created_at', ascending: false); // Show newest first

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching all articles: $e');
      throw Exception('Failed to load articles: ${e.toString()}');
    }
  }

  /// Fetches articles written by a specific doctor.
  Future<List<Map<String, dynamic>>> getArticlesByDoctor(String doctorId) async {
    if (doctorId.isEmpty) {
      throw Exception('Doctor ID cannot be empty.');
    }
    try {
      // Fetch only articles by the specified doctor
      final response = await _supabase
          .from('health_articles')
          .select('article_id, title, content, created_at, updated_at') // No need to fetch author info here
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching doctor articles: $e');
      throw Exception('Failed to load your articles: ${e.toString()}');
    }
  }

   /// Fetches a single article by its ID, including author details.
  Future<Map<String, dynamic>> getArticleById(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('Article ID cannot be empty.');
    }
    try {
      final response = await _supabase
          .from('health_articles')
          .select('''
            article_id,
            title,
            content,
            created_at,
            updated_at,
            author:doctor_id (
              id,
              title,
              first_name,
              last_name
            )
          ''')
          .eq('article_id', articleId)
          .maybeSingle(); // Use maybeSingle as ID should be unique

      if (response == null) {
        throw Exception('Article not found.');
      }
      return response;
    } catch (e) {
      debugPrint('Error fetching article by ID: $e');
      throw Exception('Failed to load article details: ${e.toString()}');
    }
  }

  /// Creates a new health article.
  Future<void> createArticle({
    required String doctorId,
    required String title,
    required String content,
  }) async {
    if (doctorId.isEmpty || title.trim().isEmpty || content.trim().isEmpty) {
      throw Exception('Doctor ID, Title, and Content are required.');
    }
    try {
      await _supabase.from('health_articles').insert({
        'article_id': _uuid.v4(), // Generate new UUID
        'doctor_id': doctorId,
        'title': title.trim(),
        'content': content.trim(),
        // created_at and updated_at have default values
      });
    } catch (e) {
      debugPrint('Error creating article: $e');
      throw Exception('Failed to create article: ${e.toString()}');
    }
  }

  /// Updates an existing health article.
  Future<void> updateArticle({
    required String articleId,
    required String doctorId, // Ensure the correct doctor is updating
    required String title,
    required String content,
  }) async {
    if (articleId.isEmpty || doctorId.isEmpty || title.trim().isEmpty || content.trim().isEmpty) {
      throw Exception('Article ID, Doctor ID, Title, and Content are required.');
    }
    try {
      await _supabase
          .from('health_articles')
          .update({
            'title': title.trim(),
            'content': content.trim(),
            'updated_at': DateTime.now().toIso8601String(), // Explicitly update timestamp
          })
          .eq('article_id', articleId)
          .eq('doctor_id', doctorId); // RLS also enforces this, but good practice
    } catch (e) {
      debugPrint('Error updating article: $e');
      throw Exception('Failed to update article: ${e.toString()}');
    }
  }

  /// Deletes a health article.
  Future<void> deleteArticle({
    required String articleId,
    required String doctorId, // Ensure the correct doctor is deleting
  }) async {
    if (articleId.isEmpty || doctorId.isEmpty) {
      throw Exception('Article ID and Doctor ID are required.');
    }
    try {
      await _supabase
          .from('health_articles')
          .delete()
          .eq('article_id', articleId)
          .eq('doctor_id', doctorId); // RLS also enforces this
    } catch (e) {
      debugPrint('Error deleting article: $e');
      throw Exception('Failed to delete article: ${e.toString()}');
    }
  }

  /// Helper to format doctor name from author map
  String getAuthorDisplayName(Map<String, dynamic>? authorData) {
    if (authorData == null) return 'Unknown Author';
    return '${authorData['title'] ?? ''} ${authorData['first_name'] ?? ''} ${authorData['last_name'] ?? ''}'.trim();
  }
}
