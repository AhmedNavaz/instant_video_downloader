class Post {
  String? id;
  String? link;
  String? url;
  String? title;
  String? thumbnail;
  double? duration;
  String? username;
  String? profilePic;

  Post({
    this.id,
    this.link,
    this.url,
    this.title,
    this.thumbnail,
    this.duration,
    this.username,
    this.profilePic,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        url: json["url"],
        title: json["title"],
        thumbnail: json["thumbnail"],
        duration: json["duration"],
        username: json["username"],
        profilePic: json["profilePic"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
        "title": title,
        "thumbnail": thumbnail,
        "duration": duration,
        "username": username,
        "profilePic": profilePic,
      };
}
