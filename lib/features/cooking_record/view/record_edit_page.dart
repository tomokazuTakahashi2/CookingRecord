import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';
import 'package:cooking_record/features/cooking_record/provider/cooking_record_provider.dart';
import 'package:cooking_record/features/cooking_record/data/cooking_record_repository.dart';
import 'package:cooking_record/features/cooking_record/widget/placeholder_image.dart';
import 'package:cooking_record/features/cooking_record/widget/header_app_bar.dart';
import 'package:cooking_record/features/cooking_record/widget/rating_stars.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_record/app/utils.dart';

class RecordEditPage extends ConsumerStatefulWidget {
  const RecordEditPage({
    super.key,
    required this.record,
  });

  final CookingRecord record;

  @override
  ConsumerState<RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends ConsumerState<RecordEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dishNameController;
  late final TextEditingController _memoController;
  late final TextEditingController _referenceUrlController;
  String? _imagePath;
  late int _rating;
  bool _isEdited = false;
  bool _isSaving = false; // 保存中の状態を管理
  bool _isNewImagePick = false; // 新たに選択した画像かどうか

  void _onTextChanged() {
    setState(() {
      _isEdited = true;
    });
  }

  bool get _hasChanges {
    return _isEdited ||
        _dishNameController.text != widget.record.dishName ||
        _memoController.text != (widget.record.memo ?? '') ||
        _referenceUrlController.text != (widget.record.referenceUrl ?? '') ||
        _imagePath != widget.record.photoPath ||
        _rating != widget.record.rating;
  }
  
  // URLバリデーション関数を共通化
  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;

    if (!value.startsWith('https://')) {
      return 'URLはhttps://で始まる必要があります（安全な接続）';
    }

    Uri? uri;
    try {
      uri = Uri.parse(value);
    } catch (_) {
      return '有効なURLを入力してください';
    }

    if (uri.host.isEmpty || !uri.host.contains('.')) {
      return '有効なドメイン名が必要です (例: example.com)';
    }

    final segments = uri.host.split('.');
    if (segments.last.length < 2) {
      return '有効なドメイン名が必要です (例: .com, .jp)';
    }

    // ホストに日本語などが混ざったら弾く（.comあ を確実に弾く）
    final hostOk = RegExp(r'^[A-Za-z0-9.-]+$').hasMatch(uri.host);
    final punycodeOk = uri.host.startsWith('xn--'); // 国際化ドメイン許可
    if (!hostOk && !punycodeOk) {
      return 'ドメイン名に使用できない文字が含まれています';
    }

    // 正規表現でさらに厳密に検証
    final urlRegex = RegExp(
      r'^(https:\/\/)'
      r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|'
      r'((\d{1,3}\.){3}\d{1,3}))'
      r'(\:\d+)?(\/[-a-z\d%_.~+]*)*'
      r'(\?[;&a-z\d%_.~+=-]*)?'
      r'(\#[-a-z\d_]*)?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value)) {
      return '有効なURLの形式ではありません';
    }

    return null;
  }

  // 共通のバリデーション関数を使用
  bool _hasValidUrl() => _validateUrl(_referenceUrlController.text) == null;

  @override
  void initState() {
    super.initState();
    _dishNameController = TextEditingController(text: widget.record.dishName)
      ..addListener(_onTextChanged);
    _memoController = TextEditingController(text: widget.record.memo ?? '')
      ..addListener(_onTextChanged);
    _referenceUrlController = TextEditingController(text: widget.record.referenceUrl ?? '')
      ..addListener(_onTextChanged);
    _imagePath = widget.record.photoPath;
    _rating = widget.record.rating;
  }

  @override
  void dispose() {
    _dishNameController.removeListener(_onTextChanged);
    _memoController.removeListener(_onTextChanged);
    _referenceUrlController.removeListener(_onTextChanged);
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
            _isEdited = true;
            _isNewImagePick = true; // 画像選択フラグをON
          });
        } else {
          showSnack('画像の読み込みに失敗しました', color: Colors.red);
        }
      }
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

      final updatedRecord = CookingRecord(
        id: widget.record.id,
        dishName: _dishNameController.text,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        createdAt: widget.record.createdAt,
        photoPath: savedImagePath ?? _imagePath,
        rating: _rating,
        referenceUrl: _referenceUrlController.text.isEmpty ? null : _referenceUrlController.text,
      );

      await ref.read(cookingRecordsProvider.notifier).updateRecord(updatedRecord);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存中にエラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderAppBar(title: '記録を編集'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () async {
            // キーボードを閉じる前に確実に入力を確定させる
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              // テキスト確定のために少し待機
              await Future<void>.delayed(Duration.zero);
            }
            currentFocus.unfocus();
          },
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
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
                                width: 120,
                                height: 120,
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
                            _isEdited = true;
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
                  decoration: InputDecoration(
                    labelText: '参考URL',
                    border: const OutlineInputBorder(),
                    hintText: 'https://example.com',
                    helperText: '有効なウェブサイトのURLを入力してください',
                    suffixIcon: (_referenceUrlController.text.isNotEmpty && _hasValidUrl())
                        ? IconButton(
                            icon: const Icon(Icons.open_in_new),
                                  onPressed: () async {
                                    final url = _referenceUrlController.text;
                                    if (url.startsWith('https://')) {
                                      try {
                                        final uri = Uri.parse(url);
                                        if (await url_launcher.canLaunchUrl(uri)) {
                                          // First try external application mode
                                          bool launched = await url_launcher.launchUrl(
                                            uri,
                                            mode: url_launcher.LaunchMode.externalApplication,
                                          );
                                          
                                          // If that fails, try platform default as fallback
                                          if (!launched) {
                                            launched = await url_launcher.launchUrl(
                                              uri,
                                              mode: url_launcher.LaunchMode.platformDefault,
                                            );
                                          }
                                          
                                          if (!launched) {
                                            showSnack('URLを開けませんでした', color: Colors.red);
                                          }
                                        } else {
                                          showSnack('このURLを処理できるアプリが見つかりません', color: Colors.red);
                                        }
                                      } catch (e) {
                                        showSnack('URLの処理中にエラーが発生しました: $e', color: Colors.red);
                                      }
                                    }
                            },
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: _validateUrl,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 32),
                Consumer(
                  builder: (context, ref, child) {
                    final recordsAsync = ref.watch(cookingRecordsProvider);
                    final isLoading = recordsAsync is AsyncLoading;

                    // 有効条件: 保存中でなく && 変更あり && 料理名が入力済み && URL検証に合格
                    final canSave = !_isSaving && !isLoading && _hasChanges && _dishNameController.text.trim().isNotEmpty && _hasValidUrl();
                    
                    return FilledButton(
                      onPressed: canSave
                          ? () async {
                              // 多重実行防止ガード
                              if (_isSaving) return;
                              
                              debugPrint('SAVE: ボタン押下');
                              
                              // 即座にボタンを無効化（多重タップ防止）
                              setState(() => _isSaving = true);
                              
                              try {
                                // キーボードを閉じる
                                FocusManager.instance.primaryFocus?.unfocus();
                                await Future<void>.delayed(Duration.zero);
                                
                                final ok = _formKey.currentState!.validate();
                                debugPrint('SAVE: validate=$ok');
                                if (!ok) return;
                                
                                // 保存中メッセージ表示
                                showSnack('保存中...', color: Colors.orange, seconds: 1);
                                
                                // Create an updated record
                                debugPrint('SAVE: start');
                                String? savedImagePath;
                                if (_imagePath != null && _isNewImagePick) {
                                  // 新しく選択した画像のみコピーする
                                  try {
                                    debugPrint('SAVE: copying new image');
                                    final sourceFile = File(_imagePath!);
                                    if (await sourceFile.exists()) {
                                      final appDir = await getApplicationDocumentsDirectory();
                                      final fileName = '${const Uuid().v4()}.jpg';
                                      final savedImage = File('${appDir.path}/$fileName');
                                      await sourceFile.copy(savedImage.path);
                                      savedImagePath = savedImage.path;
                                      debugPrint('SAVE: image copied to: $savedImagePath');
                                    } else {
                                      debugPrint('SAVE: source image not found: $_imagePath');
                                      throw Exception('画像ファイルが見つかりません');
                                    }
                                  } catch (e) {
                                    debugPrint('Error saving image: $e');
                                    throw Exception('画像の保存中にエラー: $e');
                                  }
                                }

                                final updatedRecord = CookingRecord(
                                  id: widget.record.id,
                                  dishName: _dishNameController.text,
                                  memo: _memoController.text.isEmpty ? null : _memoController.text,
                                  createdAt: widget.record.createdAt,
                                  // 新規選択画像ならsavedImagePath、選択してないなら元の画像パスを使用
                                  photoPath: savedImagePath ?? (_isNewImagePick ? _imagePath : widget.record.photoPath),
                                  rating: _rating,
                                  referenceUrl: _referenceUrlController.text.isEmpty ? null : _referenceUrlController.text,
                                );

                                debugPrint('SAVE: before updateRecord');
                                
                                try {
                                  // Providerを使用して保存 - mounted チェック前に結果受け取り
                                  final success = await ref.read(cookingRecordsProvider.notifier).updateRecord(updatedRecord);
                                  debugPrint('SAVE: updateRecord completed with success=$success');
                                
                                  // mounted チェックを先に行い、安全なら pop
                                  if (!mounted) {
                                    debugPrint('SAVE: not mounted (line C) - but save was successful=$success');
                                    return; // 画面が既に破棄されている場合は何もしない
                                  }
                                
                                  // 画面が生きているなら pop
                                  debugPrint('SAVE: about to pop with success=$success');
                                  context.pop(success);
                                  debugPrint('SAVE: popped (line D)');
                                } catch (e) {
                                  debugPrint('SAVE: updateRecord error: $e');
                                  // エラー時、画面が生きてたらスナックバーを表示
                                  if (mounted) {
                                    showSnack('保存中にエラー: $e', color: Colors.red);
                                  }
                                  throw e; // 再スロー
                                }
                                
                              } catch (e, st) {
                                debugPrint('SAVE: error=$e\n$st');
                                if (mounted) {
                                  showSnack('保存中にエラー: $e', color: Colors.red);
                                }
                              } finally {
                                // 必ず保存状態を元に戻す
                                if (mounted) setState(() => _isSaving = false);
                              }
                            }
                          : null,
                      child: _isSaving || isLoading
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
