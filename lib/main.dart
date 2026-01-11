import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cooking_record/app/app.dart';

void main() {
  debugPrint('Starting app...');
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: CookingRecordApp(),
    ),
  );
  
  debugPrint('App started');
}
