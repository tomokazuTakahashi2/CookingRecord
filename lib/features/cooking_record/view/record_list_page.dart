import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_record/features/cooking_record/provider/cooking_record_provider.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';
import 'package:cooking_record/features/cooking_record/widget/placeholder_image.dart';
import 'package:cooking_record/features/cooking_record/widget/header_app_bar.dart';
import 'package:cooking_record/features/cooking_record/widget/rating_stars.dart';
import 'package:cooking_record/features/cooking_record/widget/tag_selector.dart';
import 'package:cooking_record/app/utils.dart';

class RecordListPage extends ConsumerWidget {
  const RecordListPage({super.key});

  Future<void> _openFilterSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final selected = ref.watch(filterTagsProvider);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Text(
                            'タグで絞り込み',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (selected.isNotEmpty)
                            TextButton(
                              onPressed: () =>
                                  ref.read(filterTagsProvider.notifier).state = [],
                              child: const Text('クリア'),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        child: TagSelector(
                          selectedTags: selected,
                          onChanged: (tags) =>
                              ref.read(filterTagsProvider.notifier).state = tags,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building RecordListPage');
    final recordsAsync = ref.watch(filteredRecordsProvider);
    final filterTags = ref.watch(filterTagsProvider);

    return Scaffold(
      appBar: HeaderAppBar(
        title: '自炊記録',
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filterTags.isNotEmpty,
              label: Text('${filterTags.length}'),
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'タグで絞り込み',
            onPressed: () => _openFilterSheet(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'privacy_policy') {
                context.push('/privacy-policy');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'privacy_policy',
                child: Text('プライバシーポリシー'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (filterTags.isNotEmpty)
              _ActiveFilterBar(
                tags: filterTags,
                onRemove: (tag) {
                  final updated = List<String>.from(filterTags)..remove(tag);
                  ref.read(filterTagsProvider.notifier).state = updated;
                },
                onClear: () =>
                    ref.read(filterTagsProvider.notifier).state = [],
              ),
            Expanded(
              child: recordsAsync.when(
          data: (records) {
            debugPrint('Records count: ${records.length}');
            return records.isEmpty
                ? Center(
                    child: Text(
                      filterTags.isEmpty
                          ? '記録がありません'
                          : '条件に合う記録がありません',
                    ),
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
                        showSnack('記録を削除しました');
                      } catch (e) {
                        showSnack('削除中にエラーが発生しました: $e', color: Colors.red);
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint('FAB tapped, navigating to add page');
          final result = await context.push<bool>('/add');
          debugPrint('Returned from add page with result: $result');
          
          // 保存成功の場合はメッセージを表示し、リストを更新
          if (result == true) {
            // データを更新（キャッシュをクリアして再取得）
            ref.invalidate(cookingRecordsProvider);
            showSnack('記録を保存しました', color: Colors.green);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 一覧上部に表示する、選択中の絞り込みタグのチップ列。
class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({
    required this.tags,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> tags;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final tag in tags)
                  InputChip(
                    label: Text(tag),
                    onDeleted: () => onRemove(tag),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('クリア'),
          ),
        ],
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
      title: Row(
        children: [
          Expanded(
            child: Text(record.dishName),
          ),
          RatingStars(
            rating: record.rating,
            readOnly: true,
            size: 20.0,
          ),
        ],
      ),
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
