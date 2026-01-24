import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_record/features/cooking_record/view/record_list_page.dart';
import 'package:cooking_record/features/cooking_record/view/record_add_page.dart';
import 'package:cooking_record/features/cooking_record/view/record_detail_page.dart';
import 'package:cooking_record/features/cooking_record/view/record_edit_page.dart';
import 'package:cooking_record/features/cooking_record/view/privacy_policy_page.dart';
import 'package:cooking_record/features/cooking_record/provider/cooking_record_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Root navigator key for consistent navigation
final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RecordListPage(),
    ),
    GoRoute(
      path: '/add',
      parentNavigatorKey: rootNavigatorKey, // 確実にルートNavigatorに積むための設定
      builder: (context, state) => const RecordAddPage(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return Consumer(
          builder: (context, ref, _) {
            final recordsAsync = ref.watch(cookingRecordsProvider);
            return recordsAsync.when(
              data: (records) {
                final record = records.firstWhere((r) => r.id.toString() == id);
                return RecordDetailPage(record: record);
              },
              loading: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Scaffold(
                body: Center(
                  child: Text('エラーが発生しました: $error'),
                ),
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/edit/:id',
      parentNavigatorKey: rootNavigatorKey, // 確実にルートNavigatorに積むための設定
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return Consumer(
          builder: (context, ref, _) {
            final recordsAsync = ref.watch(cookingRecordsProvider);
            return recordsAsync.when(
              data: (records) {
                final record = records.firstWhere((r) => r.id.toString() == id);
                return RecordEditPage(record: record);
              },
              loading: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Scaffold(
                body: Center(
                  child: Text('エラーが発生しました: $error'),
                ),
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
  ],
);
