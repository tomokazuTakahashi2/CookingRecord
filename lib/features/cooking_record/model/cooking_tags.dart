/// 料理に付けられるタグの定義。
///
/// タグはカテゴリごとにグルーピングされており、編集・追加画面では
/// カテゴリ単位で複数選択できる。必須ではない。
class TagCategory {
  const TagCategory({
    required this.title,
    required this.tags,
  });

  final String title;
  final List<String> tags;
}

const List<TagCategory> kTagCategories = [
  TagCategory(
    title: '地域別',
    tags: [
      '和食',
      '中華',
      '韓国料理',
      'イタリアン',
      'フレンチ',
      'スペイン料理',
      'インド料理',
      'タイ料理',
      'ベトナム料理',
      'メキシコ料理',
      'トルコ料理',
      '創作',
    ],
  ),
  TagCategory(
    title: '調理法',
    tags: [
      '焼き物',
      '揚げ物',
      '煮物',
      '蒸し物',
      '炒め物',
      '茹で物',
      '燻製',
      '生食',
      '漬物',
    ],
  ),
  TagCategory(
    title: '食材別',
    tags: [
      '肉料理',
      '魚介料理',
      '野菜料理',
      '卵料理',
      '麺料理',
      '米料理',
      '豆料理',
      'パスタ',
      'スイーツ',
    ],
  ),
];
