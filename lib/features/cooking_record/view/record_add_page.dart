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

class RecordAddPage extends ConsumerStatefulWidget {
  const RecordAddPage({super.key});

  @override
  ConsumerState<RecordAddPage> createState() => _RecordAddPageState();
}

class _RecordAddPageState extends ConsumerState<RecordAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _dishNameController = TextEditingController();
  final _memoController = TextEditingController();
  String? _imagePath;

  @override
  void dispose() {
    _dishNameController.dispose();
    _memoController.dispose();
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

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
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
            }
          } catch (e) {
            debugPrint('Error saving image: $e');
            rethrow;
          }
        }

        final record = CookingRecord(
          id: const Uuid().v4(),
          dishName: _dishNameController.text,
          memo: _memoController.text.isEmpty ? null : _memoController.text,
          createdAt: DateTime.now(),
          photoPath: savedImagePath,
        );

        await ref.read(cookingRecordsProvider.notifier).addRecord(record);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存中にエラーが発生しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderAppBar(title: '記録を追加'),
      body: SafeArea(
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
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  border: OutlineInputBorder(),
                ),
                validator: null,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, child) {
                  final recordsAsync = ref.watch(cookingRecordsProvider);
                  final isLoading = recordsAsync.isLoading;

                  return FilledButton(
                    onPressed: isLoading ? null : _saveRecord,
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
    );
  }
}
