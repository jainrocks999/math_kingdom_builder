class HomeActionModel {
  const HomeActionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.iconKey,
    required this.emoji,
    required this.imagePath,
    required this.colorHex,
    required this.softColorHex,
    required this.shadowColorHex,
  });

  final String id;
  final String title;
  final String subtitle;
  final String route;
  final String iconKey;
  final String emoji;
  final String imagePath;
  final String colorHex;
  final String softColorHex;
  final String shadowColorHex;

  factory HomeActionModel.fromJson(Map<String, dynamic> json) {
    return HomeActionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      route: json['route'] as String,
      iconKey: json['iconKey'] as String,
      emoji: json['emoji'] as String,
      imagePath: json['imagePath'] as String,
      colorHex: json['colorHex'] as String,
      softColorHex: json['softColorHex'] as String,
      shadowColorHex: json['shadowColorHex'] as String,
    );
  }
}
