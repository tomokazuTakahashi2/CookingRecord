import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cooking_record/features/cooking_record/provider/cooking_record_provider.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';
import 'package:cooking_record/features/cooking_record/widget/placeholder_image.dart';
import 'package:cooking_record/features/cooking_record/widget/header_app_bar.dart';

class RecordListPage extends ConsumerWidget {
  const RecordListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building RecordListPage');
    final recordsAsync = ref.watch(cookingRecordsProvider);

    return Scaffold(
      appBar: const HeaderAppBar(title: '自炊記録'),
      body: SafeArea(
        child: recordsAsync.when(
          data: (records) {
            debugPrint('Records count: ${records.length}');
            return records.isEmpty
                ? const Center(
                    child: Text('記録がありません'),
                  )
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                  final record = records[index];
                  return Dismissible(
                    key: Key(record.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) async {
                      try {
                        // 写真ファイルの削除
                        if (record.photoPath != null) {
                          final file = File(record.photoPath!);
                          if (await file.exists()) {
                            await file.delete();
                          }
                        }
                        // レコードの削除
                        await ref.read(cookingRecordsProvider.notifier).deleteRecord(record.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('記録を削除しました'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('削除中にエラーが発生しました: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: RecordListTile(record: record),
                  );
                    },
                  );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text('エラーが発生しました: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB tapped, navigating to add page');
          context.push('/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RecordListTile extends StatelessWidget {
  const RecordListTile({
    super.key,
    required this.record,
  });

  final CookingRecord record;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: record.photoPath != null
          ? SizedBox(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(record.photoPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const PlaceholderImage(
                      size: 60,
                      iconSize: 24,
                    );
                  },
                ),
              ),
            )
          : const PlaceholderImage(
              size: 60,
              iconSize: 24,
            ),
      title: Text(record.dishName),
      subtitle: Text(
        _formatDate(record.createdAt),
      ),
      onTap: () {
        context.push('/detail/${record.id}');
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}';
  }
}
