class SurahModel {
  final int id;
  final String name;
  final String nameEn;
  final String nameTranslation;
  final int words;
  final int letters;
  final String type;
  final String typeEn;
  final String ar;
  final String en;
  final List<AyahModel> array;

  SurahModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameTranslation,
    required this.words,
    required this.letters,
    required this.type,
    required this.typeEn,
    required this.ar,
    required this.en,
    required this.array,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameTranslation: json['name_translation'] ?? '',
      words: json['words'] ?? 0,
      letters: json['letters'] ?? 0,
      type: json['type'] ?? '',
      typeEn: json['type_en'] ?? '',
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
      array: (json['array'] as List?)?.map((e) => AyahModel.fromJson(e)).toList() ?? [],
    );
  }
}

class AyahModel {
  final int id;
  final String ar;
  final String en;

  AyahModel({
    required this.id,
    required this.ar,
    required this.en,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      id: json['id'] ?? 0,
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}
