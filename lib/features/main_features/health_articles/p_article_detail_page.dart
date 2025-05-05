import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/health_articles/health_articles_db.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; 

class PatientArticleDetailPage extends StatefulWidget {
  final String articleId;

  const PatientArticleDetailPage({
    Key? key,
    required this.articleId,
  }) : super(key: key);

  @override
  _PatientArticleDetailPageState createState() => _PatientArticleDetailPageState();
}

class _PatientArticleDetailPageState extends State<PatientArticleDetailPage> {
  final HealthArticlesDB _db = HealthArticlesDB();
  Map<String, dynamic>? _articleData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final article = await _db.getArticleById(widget.articleId);
      if (!mounted) return;
      setState(() {
        _articleData = article;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMMM dd, yyyy \'at\' hh:mm a').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading || _articleData == null ? 'Loading Article...' : _articleData!['title'] ?? 'Article'),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red))))
              : _articleData == null
                  ? const Center(child: Text('Article not found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _articleData!['title'] ?? 'Untitled Article',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppPallete.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By ${_db.getAuthorDisplayName(_articleData!['author'])}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Published: ${_formatDate(_articleData!['created_at'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_articleData!['updated_at'] != null && _articleData!['updated_at'] != _articleData!['created_at'])
                            Text(
                              'Updated: ${_formatDate(_articleData!['updated_at'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          const Divider(height: 24, thickness: 1),
                          // Use Markdown widget to render content
                          MarkdownBody(
                            data: _articleData!['content'] ?? 'No content available.',
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 16, height: 1.5), // Style paragraphs
         
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
