import 'package:flutter/material.dart';
import 'package:cooking_record/app/router.dart';

class CookingRecordApp extends StatelessWidget {
  const CookingRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building CookingRecordApp');
    return MaterialApp.router(
      title: '自炊記録',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        debugPrint('Building app with child: ${child.runtimeType}');
        return child!;
      },
    );
  }
}
