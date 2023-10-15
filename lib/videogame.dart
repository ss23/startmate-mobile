
// https://developer.start.gg/reference/videogame.doc
class VideoGame {
  int id;
  String? displayName;
  String name;
  String? slug;

  String? imageURL;

  VideoGame(this.id, this.name, this.imageURL);

  /*
  # All characters for this videogame
  characters: [Character]
  images(type: String): [Image]
  stages: [Stage]
  */
}