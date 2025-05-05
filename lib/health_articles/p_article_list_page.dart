import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/health_articles/health_articles_db.dart';

class PatientArticleListPage extends StatefulWidget {
  const PatientArticleListPage({Key? key}) : super(key: key);

  @override
  _PatientArticleListPageState createState() => _PatientArticleListPageState();
}

class _PatientArticleListPageState extends State<PatientArticleListPage> {
  final HealthArticlesDB _db = HealthArticlesDB();
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final articles = await _db.getAllArticles();
      if (!mounted) return;
      setState(() {
        _articles = articles;
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
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Articles & Tips'),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
         leading: context.canPop() ? BackButton(onPressed: () => context.pop()) : null,
      ),
      body: RefreshIndicator(
        onRefresh: _loadArticles,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red))))
                : _articles.isEmpty
                    ? const Center(child: Text('No articles available yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: _articles.length,
                        itemBuilder: (context, index) {
                          final article = _articles[index];
                          final authorName = _db.getAuthorDisplayName(article['author']);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              title: Text(
                                article['title'] ?? 'Untitled Article',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'By $authorName • ${_formatDate(article['created_at'])}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppPallete.greyColor),
                              onTap: () {
                                // Navigate to detail page using GoRouter
                                context.push('/patient/articles/${article['article_id']}');
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
