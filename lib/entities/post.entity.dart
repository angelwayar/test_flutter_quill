class PostEntity {
  PostEntity({
    this.id,
    this.author,
    this.localizedContent,
    this.tags,
    this.urlImage,
    this.thumbnailImage,
    this.publishDate,
    this.viewCount,
    this.status,
  });

  String? id;
  String? author;
  List<LocalizedContentEntity>? localizedContent;
  List<TagEntity>? tags;
  List<String>? urlImage;
  String? thumbnailImage;
  String? publishDate;
  int? viewCount;
  String? status;
}

class LocalizedContentEntity {
  LocalizedContentEntity({
    this.language,
    this.title,
    this.content,
    this.summary,
    this.description,
    this.id,
  });

  String? language;
  String? title;
  String? content;
  String? summary;
  String? description;
  String? id;
}

class TagEntity {
  TagEntity({
    this.id,
    this.type,
    this.name,
  });
  final String? id;
  final String? type;
  final String? name;
}

var postEntity = PostEntity(
  author: 'Angel Wayar',
  publishDate: DateTime.now().toString(),
  status: 'publicado',
  urlImage: [''],
  thumbnailImage: '',
  viewCount: 0,
  tags: [
    TagEntity(
      type: 'en',
      name: 'startup',
    ),
    TagEntity(
      type: 'en',
      name: 'innovation',
    ),
  ],
  localizedContent: [
    LocalizedContentEntity(
      language: "en",
      title: "¿Cómo mejorar tu productividad?",
      content: "",
      description:
          "Guía completa sobre técnicas de productividad y gestión del tiempo",
      summary:
          "Descubre las mejores técnicas para aumentar tu productividad y lograr más en menos tiempo",
    )
  ],
);
