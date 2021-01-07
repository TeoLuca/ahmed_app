class Playlist {
  int id;
  String title;

  Playlist(this.title);

  Map<String, dynamic> toMap() {
    Map map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    return map;
  }

  // Convert Map object to a Task object
  Playlist.fromMapToObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
  }
}
