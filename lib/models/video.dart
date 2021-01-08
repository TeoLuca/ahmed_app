class Video {
  int id;
  String title;
  String uri;
  Video(this.uri, this.title);

  Map<String, dynamic> toMap() {
    Map map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['uri'] = uri;
    return map;
  }

  // Convert Map object to a Video object
  Video.fromMapToObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.uri = map['uri'];
  }
}
