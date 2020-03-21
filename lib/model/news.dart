class News {
  final String title;
  final String description;
  final String url;
  final String urlToImage;

  News({this.title, this.description, this.url, this.urlToImage});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
    );
  }
}
