class QuestModel {
  const QuestModel({
    required this.id,
    required this.label,
    required this.route,
    required this.iconKey,
    required this.emoji,
    required this.description,
    required this.stars,
    required this.imagePath,
    required this.colorHex,
    required this.softColorHex,
    required this.shadowColorHex,
    required this.isComingSoon,
  });

  final String id;
  final String label;
  final String route;
  final String iconKey;
  final String emoji;
  final String description;
  final int stars;
  final String imagePath;
  final String colorHex;
  final String softColorHex;
  final String shadowColorHex;
  final bool isComingSoon;

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String,
      label: json['label'] as String,
      route: json['route'] as String,
      iconKey: json['iconKey'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      stars: json['stars'] as int,
      imagePath: json['imagePath'] as String,
      colorHex: json['colorHex'] as String,
      softColorHex: json['softColorHex'] as String,
      shadowColorHex: json['shadowColorHex'] as String,
      isComingSoon: json['isComingSoon'] as bool? ?? false,
    );
  }
}
