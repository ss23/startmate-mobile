// https://developer.start.gg/reference/user.doc
class User {
  int? id;
  String? bio;
  String? birthday;
  String? discriminator; // Uniquely identifying token for user. Same as the hashed part of the slug
  String? email;
  String? genderPronoun;
  String? name;
  String? slug;

  // Not fields in the API
  String? bannerImage;
  String? profileImage; // An avatar, approximately

  // A list of events that are upcoming that the user is participating in
  List<int> upcomingEvents = [];

  User(this.id, this.name, this.profileImage);

  /*
  # Authorizations to external services (i.e. Twitch, Twitter)
  authorizations(types: [SocialConnectionType]): [ProfileAuthorization]
  # Events this user has competed in
  events(query: UserEventsPaginationQuery): EventConnection
  images(type: String): [Image]
  # Leagues this user has competed in
  leagues(query: UserLeaguesPaginationQuery): LeagueConnection
  # Public location info for this user
  location: Address
  # player for user
  player: Player
  # Tournaments this user is organizing or competing in
  tournaments(query: UserTournamentsPaginationQuery): TournamentConnection
  */
}