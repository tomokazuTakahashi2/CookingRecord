import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プライバシーポリシー',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '本プライバシーポリシーは、Cooking Record（以下「本アプリ」）の利用において、ユーザーの個人情報の取り扱いについて説明するものです。',
            ),
            SizedBox(height: 16),
            Text(
              '1. 収集する情報',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '本アプリでは、以下の情報を収集・保存します：\n'
              '• 料理の記録（写真、メモ、評価等）\n'
              '• アプリの利用状況に関する情報',
            ),
            SizedBox(height: 16),
            Text(
              '2. 情報の利用目的',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '収集した情報は以下の目的で利用されます：\n'
              '• アプリの基本機能の提供\n'
              '• サービスの改善と新機能の開発\n'
              '• 技術的な問題の解決',
            ),
            SizedBox(height: 16),
            Text(
              '3. 情報の保管',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '収集した情報は、ユーザーのデバイス内にのみ保存され、外部サーバーには送信されません。',
            ),
            SizedBox(height: 16),
            Text(
              '4. 情報の削除',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ユーザーは、アプリ内で記録した情報をいつでも削除することができます。また、アプリをアンインストールすることで、すべての情報が完全に削除されます。',
            ),
            SizedBox(height: 16),
            Text(
              '5. プライバシーポリシーの変更',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '本プライバシーポリシーは、必要に応じて変更される場合があります。変更があった場合は、アプリ内で通知いたします。',
            ),
            SizedBox(height: 16),
            Text(
              '6. お問い合わせ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'プライバシーポリシーに関するご質問やご意見がございましたら、アプリ開発者までお問い合わせください。',
            ),
          ],
        ),
      ),
    );
  }
}
