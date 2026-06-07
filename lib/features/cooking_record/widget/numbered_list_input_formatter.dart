import 'package:flutter/services.dart';

/// 改行をタップしたときに、自動で「1. 2. 3.」と連番を付ける入力フォーマッタ。
///
/// 挙動（iOS純正メモの番号付きリストに近い動き）:
/// - 番号なしの行で改行 → その行頭に `1. ` を付け、新しい行を `2. ` で始める
/// - `N. ` で始まる行で改行 → 新しい行を `(N+1). ` で始める
/// - `N. ` だけの空項目で改行 → 番号を消してリストを終了する
class NumberedListInputFormatter extends TextInputFormatter {
  static final _numberPrefix = RegExp(r'^(\d+)\.\s');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1文字だけ挿入されたケースのみ対象にする（貼り付け等は対象外）
    if (newValue.text.length != oldValue.text.length + 1) {
      return newValue;
    }

    final cursor = newValue.selection.baseOffset;
    // 直前に挿入された文字が改行でなければ何もしない
    if (cursor <= 0 || newValue.text[cursor - 1] != '\n') {
      return newValue;
    }

    // 改行直前の行（今いた行）を取り出す
    final beforeNewline = newValue.text.substring(0, cursor - 1);
    final lineStart = beforeNewline.lastIndexOf('\n') + 1;
    final currentLine = beforeNewline.substring(lineStart);

    final match = _numberPrefix.firstMatch(currentLine);

    if (match != null) {
      final number = int.parse(match.group(1)!);
      final content = currentLine.substring(match.end);

      // 「N. 」だけの空項目で改行 → リストを終了（番号と改行を削除）
      if (content.trim().isEmpty) {
        final head = newValue.text.substring(0, lineStart);
        final tail = newValue.text.substring(cursor);
        final text = head + tail;
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: head.length),
        );
      }

      // 番号付きの行 → 次の番号を付けて継続
      return _insertPrefix(newValue, cursor, '${number + 1}. ');
    }

    // 番号なしの行で改行 → 今の行を「1. 」始まりにして、新しい行を「2. 」に
    final head = newValue.text.substring(0, lineStart);
    final tail = newValue.text.substring(cursor);
    final renumbered = '1. $currentLine';
    final text = '$head$renumbered\n2. $tail';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: '$head$renumbered\n2. '.length),
    );
  }

  TextEditingValue _insertPrefix(
    TextEditingValue value,
    int cursor,
    String prefix,
  ) {
    final head = value.text.substring(0, cursor);
    final tail = value.text.substring(cursor);
    return TextEditingValue(
      text: '$head$prefix$tail',
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
  }
}
