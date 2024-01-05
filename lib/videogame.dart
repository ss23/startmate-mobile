// https://developer.start.gg/reference/videogame.doc
class VideoGame {
  VideoGame(this.id, this.name, this.imageURL);

  int id;
  String? displayName;
  String name;
  String? slug;

  String? imageURL;

  /*
  # All characters for this videogame
  characters: [Character]
  images(type: String): [Image]
  stages: [Stage]
  */
}
