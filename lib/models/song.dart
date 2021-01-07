class Song {
  int id;
  String title;
  String uri;
  Song(this.uri, this.title);

  Map<String, dynamic> toMap() {
    Map map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['uri'] = uri;
    return map;
  }

  // Convert Map object to a Task object
  Song.fromMapToObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.uri = map['uri'];
  }
}
