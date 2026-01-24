import 'dart:io';
import 'dart:async';
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
import 'package:cooking_record/app/utils.dart';
import 'package:cooking_record/features/cooking_record/widget/placeholder_image.dart';
import 'package:cooking_record/features/cooking_record/widget/header_app_bar.dart';
import 'package:cooking_record/features/cooking_record/widget/rating_stars.dart';
import 'package:go_router/go_router.dart';

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
  bool _isSaving = false; // ボタン保存状態を管理
  bool _isNewImagePick = false; // 新たに選択した画像かどうか

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
  
  // Use late final to store a reference to the callback function
  late final VoidCallback _rebuild;

  @override
  void initState() {
    super.initState();
    _rebuild = () { 
      if (mounted) setState(() {}); 
    };
    _dishNameController.addListener(_rebuild);
    _referenceUrlController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _dishNameController.removeListener(_rebuild);
    _referenceUrlController.removeListener(_rebuild);
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
            _isNewImagePick = true; // 画像選択フラグをON
          });
        } else {
          showSnack('画像の読み込みに失敗しました', color: Colors.red);
        }
      }
    }
  }

  // This method is now only called when form is already validated
  Future<bool> _saveRecord() async {
    try {
      String? savedImagePath;
      if (_imagePath != null && _isNewImagePick) {
        try {
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
            showSnack('画像の保存に失敗しました', color: Colors.red);
            throw Exception('画像の保存に失敗しました');
          }
        } catch (e) {
          debugPrint('Error saving image: $e');
          showSnack('画像の保存中にエラーが発生しました: $e', color: Colors.red);
          throw Exception('画像の保存中にエラーが発生しました: $e');
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

      // Try direct repository access instead of going through provider
      debugPrint('SAVE: Using direct save method to bypass provider complexity');
      final repository = ref.read(cookingRecordRepositoryProvider);
      
      // Use the simpler direct save method first
      final directResult = await repository.saveRecordDirect(record);
      debugPrint('SAVE: Direct save result: $directResult');
      
      if (directResult) {
        // If direct save worked, update UI via provider (but don't wait for it)
        debugPrint('SAVE: Updating provider state asynchronously');
        ref.read(cookingRecordsProvider.notifier).getRecords().then(
          (value) => debugPrint('SAVE: Provider state updated successfully'),
          onError: (e) => debugPrint('SAVE: Provider state update failed: $e'),
        );
        
        debugPrint('SAVE: Direct save completed successfully');
      } else {
        debugPrint('SAVE: Direct save failed');
        throw Exception('直接保存に失敗しました');
      }
      return true; // Success
    } catch (e) {
      showSnack('保存中にエラーが発生しました: $e', color: Colors.red);
      debugPrint('SAVE: Error in _saveRecord: $e');
      return false; // Failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderAppBar(title: '記録を追加'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              try {
                                final uri = Uri.parse(url);
                                if (await url_launcher.canLaunchUrl(uri)) {
                                  bool launched = await url_launcher.launchUrl(
                                    uri,
                                    mode: url_launcher.LaunchMode.externalApplication,
                                  );
                                  
                                  if (!launched) {
                                    showSnack('URLを開けませんでした', color: Colors.red);
                                  }
                                } else {
                                  showSnack('このURLを処理できるアプリが見つかりません', color: Colors.red);
                                }
                              } catch (e) {
                                showSnack('URLの処理中にエラーが発生しました: $e', color: Colors.red);
                              }
                            },
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: _validateUrl,
                ),
                const SizedBox(height: 32),
                Consumer(
                  builder: (context, ref, _) {
                    final recordsAsync = ref.watch(cookingRecordsProvider);
                    final isLoading = recordsAsync.isLoading;
                    
                    // 有効条件: 保存中でなく && ロード中でなく && 料理名が入力済み && URL検証に合格
                    final canSave = !_isSaving 
                      && !isLoading
                      && _dishNameController.text.trim().isNotEmpty
                      && _hasValidUrl();

                    return FilledButton(
                      onPressed: canSave ? () async {
                        // 多重実行防止ガード
                        if (_isSaving) return;
                        
                        // 押下確認ログ
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
                          
                          debugPrint('SAVE: start');
                          debugPrint('SAVE: before addRecord');
                          
                          // 保存処理実行 - 直接リポジトリを使用
                          final repository = ref.read(cookingRecordRepositoryProvider);
                          
                          // レコード作成
                          String? savedImagePath;
                          if (_imagePath != null && _isNewImagePick) {
                            try {
                              final sourceFile = File(_imagePath!);
                              if (await sourceFile.exists()) {
                                final appDir = await getApplicationDocumentsDirectory();
                                final fileName = '${const Uuid().v4()}.jpg';
                                final savedImage = File('${appDir.path}/$fileName');
                                await sourceFile.copy(savedImage.path);
                                savedImagePath = savedImage.path;
                                debugPrint('SAVE: image copied to: $savedImagePath');
                              } else {
                                throw Exception('画像ファイルが見つかりません: $_imagePath');
                              }
                            } catch (e) {
                              debugPrint('SAVE: 画像保存エラー: $e');
                              throw e;
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
                          
                          // 直接リポジトリで保存（Providerを介さない）
                          await repository.addRecord(record);
                          
                          debugPrint('SAVE: after addRecord (line A)');
                          await Future<void>.delayed(Duration.zero);
                          debugPrint('SAVE: before pop (line B)');
                          
                          // 成功フラグを設定
                          final success = true;
                          
                          // 画像フラグリセット
                          _isNewImagePick = false;
                          
                          // 画面を閉じる
                          if (!mounted) {
                            debugPrint('SAVE: not mounted (line C)');
                            return;
                          }
                          
                          debugPrint('SAVE: about to pop');
                          context.pop(true);
                          debugPrint('SAVE: popped (line D)');
                          
                        } catch (e, st) {
                          debugPrint('SAVE: error=$e\n$st');
                          if (mounted) {
                            showSnack('保存中にエラー: $e', color: Colors.red);
                          }
                        } finally {
                          // 必ず保存状態を元に戻す（すべての経路で確実に）
                          if (mounted) setState(() => _isSaving = false);
                        }
                      } : null,
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
