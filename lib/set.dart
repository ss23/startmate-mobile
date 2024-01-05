import 'package:startmate/event.dart';
import 'package:startmate/phasegroup.dart';

// https://developer.start.gg/reference/set.doc
class GGSet {
  GGSet(this.id);

  dynamic id; // ID can be a string if it is just a preview
  DateTime? completedAt;
  DateTime? createdAt;
  Event? event;
  String? fullRoundText;
  bool? hasPlaceholder;
  String? identifier;
  int? lPlacement;
  PhaseGroup? phaseGroup;
  int? round;
  int? setGamesType;
  DateTime? startAt;
  DateTime? startedAt;
  int? state;
  int? totalGames;
  String? vodUrl;
  int? wPlacement;
  int? winnerId;

  /*
  displayScore(mainEntrantId: ID): String
  game(orderNum: Int!): Game
  games: [Game]
  images(type: String): [Image]
  slots(includeByes: Boolean): [SetSlot]
  # Tournament event station for a set
  station: Stations
  # Tournament event stream for a set
  stream: Streams
  */
}
