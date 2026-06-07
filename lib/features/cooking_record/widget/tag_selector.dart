import 'package:flutter/material.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_tags.dart';

/// カテゴリごとにタグを複数選択できるウィジェット。
///
/// 選択は任意（必須ではない）。選択状態が変わるたびに [onChanged] が
/// 最新の選択タグ一覧で呼ばれる。
class TagSelector extends StatelessWidget {
  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onChanged,
  });

  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;

  void _toggle(String tag) {
    final updated = List<String>.from(selectedTags);
    if (updated.contains(tag)) {
      updated.remove(tag);
    } else {
      updated.add(tag);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タグ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '任意で選択できます',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        for (final category in kTagCategories) ...[
          Text(
            category.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tag in category.tags)
                FilterChip(
                  label: Text(tag),
                  selected: selectedTags.contains(tag),
                  onSelected: (_) => _toggle(tag),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
