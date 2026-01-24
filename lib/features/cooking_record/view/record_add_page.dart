import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';
import 'package:cooking_record/features/cooking_record/provider/cooking_record_provider.dart';
import 'package:cooking_record/features/cooking_record/widget/placeholder_image.dart';
import 'package:cooking_record/features/cooking_record/widget/header_app_bar.dart';
import 'package:cooking_record/features/cooking_record/widget/rating_stars.dart';

class RecordAddPage extends ConsumerStatefulWidget {
  const RecordAddPage({super.key});

  @override
  ConsumerState<RecordAddPage> createState() => _RecordAddPageState();
}

class _RecordAddPageState extends ConsumerState<RecordAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _dishNameController = TextEditingController();
  final _memoController = TextEditingController();
  final _referenceUrlController = TextEditingController();
  String? _imagePath;
  int _rating = 0;

  @override
  void dispose() {
    _dishNameController.dispose();
    _memoController.dispose();
    _referenceUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('カメラで撮影'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('写真ライブラリから選択'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _imagePath = file.path;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('画像の読み込みに失敗しました'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  // This method is now only called when form is already validated
  Future<void> _saveRecord() async {
    try {
      String? savedImagePath;
      if (_imagePath != null) {
        try {
          final sourceFile = File(_imagePath!);
          if (await sourceFile.exists()) {
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = '${const Uuid().v4()}.jpg';
            final savedImage = File('${appDir.path}/$fileName');
            await sourceFile.copy(savedImage.path);
            savedImagePath = savedImage.path;
            debugPrint('Saved image to: $savedImagePath');
          } else {
            debugPrint('Source image not found: $_imagePath');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('画像の保存に失敗しました'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        } catch (e) {
          debugPrint('Error saving image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('画像の保存中にエラーが発生しました: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final record = CookingRecord(
        id: const Uuid().v4(),
        dishName: _dishNameController.text,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        createdAt: DateTime.now(),
        photoPath: savedImagePath,
        rating: _rating,
        referenceUrl: _referenceUrlController.text.isEmpty ? null : _referenceUrlController.text,
      );

      await ref.read(cookingRecordsProvider.notifier).addRecord(record);
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存中にエラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw e; // Rethrow so the caller knows the save failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderAppBar(title: '記録を追加'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const PlaceholderImage();
                              },
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 100,
                                child: PlaceholderImage(
                                  iconSize: 24,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'タップして写真を追加',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dishNameController,
                  decoration: const InputDecoration(
                    labelText: '料理名',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '料理名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        '評価',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RatingStars(
                        rating: _rating,
                        onRatingChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    labelText: 'メモ',
                    border: OutlineInputBorder(),
                  ),
                  validator: null,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceUrlController,
                  decoration: const InputDecoration(
                    labelText: '参考URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com',
                    helperText: '有効なウェブサイトのURLを入力してください',
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // URL is optional
                    }
                    
                    // First check if it starts with http/https
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return 'URLはhttpまたはhttpsで始まる必要があります';
                    }
                    
                    // Try to parse the URI
                    try {
                      final uri = Uri.parse(value);
                      
                      // Check if it has a valid domain
                      if (uri.host.isEmpty || !uri.host.contains('.')) {
                        return '有効なドメイン名が必要です (例: example.com)';
                      }
                      
                      // Check if there's a valid TLD
                      final segments = uri.host.split('.');
                      if (segments.last.length < 2) {
                        return '有効なドメイン名が必要です (例: .com, .jp)';
                      }
                      
                      // Check for valid URL structure using regex
                      final RegExp urlRegex = RegExp(
                        r'^(https?:\/\/)?' // protocol
                        r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
                        r'((\d{1,3}\.){3}\d{1,3}))' // OR ip (v4) address
                        r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
                        r'(\?[;&a-z\d%_.~+=-]*)?' // query string
                        r'(\#[-a-z\d_]*)?$', // fragment locater
                        caseSensitive: false,
                      );
                      
                      if (!urlRegex.hasMatch(value)) {
                        return '有効なURLの形式ではありません';
                      }
                    } catch (e) {
                      return '有効なURLを入力してください';
                    }
                    
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Consumer(
                  builder: (context, ref, child) {
                    final recordsAsync = ref.watch(cookingRecordsProvider);
                    final isLoading = recordsAsync.isLoading;

                    return FilledButton(
                      onPressed: isLoading 
                          ? null 
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await _saveRecord();
                                  if (mounted && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  debugPrint('Error saving record: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('保存中にエラーが発生しました: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                // Show a snackbar for invalid fields
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('入力エラーがあります。入力内容を確認してください。'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('保存'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
