class Profile {
  String? id;
  String? fullName;
  String? profilePic;
  int? followers;
  int? following;
  List<dynamic>? posts;

  Profile({
    this.id,
    this.fullName,
    this.profilePic,
    this.followers,
    this.following,
    this.posts,
  });
}
