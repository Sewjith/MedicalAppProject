import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/health_articles/health_articles_db.dart';

class DoctorMyArticlesPage extends StatefulWidget {
  const DoctorMyArticlesPage({Key? key}) : super(key: key);

  @override
  _DoctorMyArticlesPageState createState() => _DoctorMyArticlesPageState();
}

class _DoctorMyArticlesPageState extends State<DoctorMyArticlesPage> {
  final HealthArticlesDB _db = HealthArticlesDB();
  List<Map<String, dynamic>> _myArticles = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadArticles();
  }

  Future<void> _initializeAndLoadArticles() async {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      _doctorId = userState.user.uid;
      if (_doctorId != null) {
        _loadMyArticles();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Could not retrieve Doctor ID.";
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User is not logged in as a doctor.";
        });
      }
    }
  }

  Future<void> _loadMyArticles() async {
    if (_doctorId == null || !mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final articles = await _db.getArticlesByDoctor(_doctorId!);
      if (!mounted) return;
      setState(() {
        _myArticles = articles;
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

  void _navigateToAddArticle() {
    context.push('/doctor/articles/create').then((result) {
      // Refresh list if an article was successfully created
      if (result == true) {
        _loadMyArticles();
      }
    });
  }

  void _navigateToEditArticle(Map<String, dynamic> article) {
     context.push('/doctor/articles/edit/${article['article_id']}', extra: article).then((result) {
       // Refresh list if an article was successfully updated
       if (result == true) {
         _loadMyArticles();
       }
     });
  }

   Future<void> _confirmDeleteArticle(String articleId) async {
    if (_doctorId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text('Are you sure you want to permanently delete this article?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _db.deleteArticle(articleId: articleId, doctorId: _doctorId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article deleted')));
          _loadMyArticles(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting article: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Articles'),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        leading: context.canPop() ? BackButton(onPressed: () => context.pop()) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create New Article',
            onPressed: _navigateToAddArticle,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyArticles,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red))))
                : _myArticles.isEmpty
                    ? const Center(child: Text('You haven\'t written any articles yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: _myArticles.length,
                        itemBuilder: (context, index) {
                          final article = _myArticles[index];
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
                                  'Created: ${_formatDate(article['created_at'])}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                   IconButton(
                                     icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueGrey),
                                     tooltip: 'Edit Article',
                                     onPressed: () => _navigateToEditArticle(article),
                                   ),
                                   IconButton(
                                     icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                     tooltip: 'Delete Article',
                                     onPressed: () => _confirmDeleteArticle(article['article_id']),
                                   ),
                                ],
                              ),
                              // Optional: Add onTap to view the article as a patient would see it
                              // onTap: () => context.push('/patient/articles/${article['article_id']}'),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
