import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/health_articles/health_articles_db.dart';

class CreateEditArticlePage extends StatefulWidget {
  final Map<String, dynamic>? articleData; // Null for creating, populated for editing

  const CreateEditArticlePage({
    Key? key,
    this.articleData,
  }) : super(key: key);

  @override
  _CreateEditArticlePageState createState() => _CreateEditArticlePageState();
}

class _CreateEditArticlePageState extends State<CreateEditArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final HealthArticlesDB _db = HealthArticlesDB();

  bool _isSaving = false;
  String? _doctorId;
  bool get _isEditing => widget.articleData != null;

  @override
  void initState() {
    super.initState();
    _initializeDoctorId();
    if (_isEditing) {
      _titleController.text = widget.articleData!['title'] ?? '';
      _contentController.text = widget.articleData!['content'] ?? '';
    }
  }

  void _initializeDoctorId() {
     final userState = context.read<AppUserCubit>().state;
     if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
        _doctorId = userState.user.uid;
     } else {
        // Handle error: Doctor not logged in
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Error: You must be logged in as a doctor.'), backgroundColor: Colors.red),
              );
              context.pop(); // Go back if not a doctor
           }
        });
     }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveArticle() async {
    if (_doctorId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error: Doctor ID not found.'), backgroundColor: Colors.red),
       );
       return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        // Update existing article
        await _db.updateArticle(
          articleId: widget.articleData!['article_id'],
          doctorId: _doctorId!,
          title: _titleController.text,
          content: _contentController.text,
        );
      } else {
        // Create new article
        await _db.createArticle(
          doctorId: _doctorId!,
          title: _titleController.text,
          content: _contentController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Article updated!' : 'Article created!'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop with result=true to indicate success
        context.pop(true);
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error saving article: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
       }
    } finally {
       if (mounted) {
         setState(() => _isSaving = false);
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Article' : 'Create Article'),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(false), // Pop with false (no change)
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save),
            tooltip: 'Save Article',
            onPressed: _isSaving ? null : _saveArticle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Article Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title.';
                  }
                   if (value.length > 255) {
                     return 'Title cannot exceed 255 characters.';
                   }
                  return null;
                },
                 textCapitalization: TextCapitalization.sentences,
                 maxLength: 255,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null, // Allows unlimited lines
                  expands: true, // Fills available space
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Write your article content here...\nYou can use Markdown for basic formatting (e.g., *italic*, **bold**, # Heading).',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    alignLabelWithHint: true, // Better alignment for multiline
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Article content cannot be empty.';
                    }
                    return null;
                  },
                   textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: 10),
               Text(
                 'Markdown supported for basic formatting.',
                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
