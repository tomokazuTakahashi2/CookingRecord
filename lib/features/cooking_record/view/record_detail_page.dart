import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';
import 'package:cooking_record/features/cooking_record/widget/placeholder_image.dart';
import 'package:cooking_record/features/cooking_record/widget/header_app_bar.dart';
import 'package:cooking_record/features/cooking_record/widget/rating_stars.dart';

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({
    super.key,
    required this.record,
  });

  final CookingRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderAppBar(
        title: '詳細',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit/${record.id}');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (record.photoPath != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(record.photoPath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const PlaceholderImage();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                record.dishName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '作成日時: ${_formatDate(record.createdAt)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              const Text(
                '評価',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RatingStars(
                  rating: record.rating,
                  readOnly: true,
                ),
              ),
              if (record.memo != null && record.memo!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'メモ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  record.memo!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}';
  }
}
