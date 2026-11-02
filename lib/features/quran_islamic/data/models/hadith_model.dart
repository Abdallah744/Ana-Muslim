class HadithModel {
  final String description;
  final String hadith;

  HadithModel({
    required this.description,
    required this.hadith,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      description: json['description'] ?? '',
      hadith: json['hadith'] ?? '',
    );
  }
}
