
// https://developer.start.gg/reference/tournament.doc
class Tournament {
  int id;
  String? addrState;
  String? city;
  String? countryCode;
  DateTime? createdAt;
  String? currency;
  DateTime? endAt;
  DateTime? eventRegistrationClosesAt;
  bool? hasOfflineEvents;
  bool? hasOnlineEvents;
  String? hashtag;
  bool? isOnline;
  bool? isRegistrationOpen;
  double? lat;
  double? lng;
  String? mapsPlaceId;
  String name;
  int? numAttendees;
  // owner? User;
  String? postalCode;
  String? primaryContact;
  String? primaryContactType;
  // JSON? publishing;
  DateTime? registrationClosesAt;
  String? rules;
  String? shortSlug;
  String? slug;
  DateTime? startAt;
  int? state; // ActivityState::CREATED, ActivityState::ACTIVE, ActivityState::COMPLETED
  DateTime? teamCreationClosesAt;
  String? timezone;
  int? tournamentType;
  DateTime? updatedAt;
  String? venueAddress;
  String? venueName;

  // Not a field in the API
  String imageURL;

  Tournament(this.id, this.name, this.imageURL);
 /*
  events(limit: Int, filter: EventFilter): [Event]
  # Arguments
  # type: [Not documented]
  images(type: String): [Image]
  links: TournamentLinks
  participants(query: ParticipantPaginationQuery!, isAdmin: Boolean): ParticipantConnection
  stations(page: Int, perPage: Int): StationsConnection
  streamQueue: [StreamQueue]
  streams: [Streams]
  teams(query: TeamPaginationQuery!): TeamConnection
  url(tab: String, relative: Boolean): String
  waves: [Wave]
 */
}