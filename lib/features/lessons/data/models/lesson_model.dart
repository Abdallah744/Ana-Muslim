class LessonModel {
  final int id;
  final String title;
  final String author;
  final String description;
  final String audioUrl;

  LessonModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.audioUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    String authorName = 'الشيخ';
    if (json['prepared_by'] != null && (json['prepared_by'] as List).isNotEmpty) {
      authorName = json['prepared_by'][0]['title'] ?? 'الشيخ';
    }

    String url = '';
    if (json['attachments'] != null && (json['attachments'] as List).isNotEmpty) {
      url = json['attachments'][0]['url'] ?? '';
    }

    return LessonModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'درس إسلامي',
      author: authorName,
      description: json['description'] ?? '',
      audioUrl: url,
    );
  }
}
