import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/event.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/tournament.dart';
import 'package:startmate/user.dart';
import 'package:startmate/videogame.dart';

part 'tournament_controller.g.dart';

@riverpod
Future<List<Tournament>> fetchTournaments(FetchTournamentsRef ref, {required filter, sortBy = "tournament.startAt desc"}) async {
  final log = Logger('fetchTournaments');
  log.fine("Fetching tournament data");

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  // Begin by getting our clients ID
  var query = r'query user { currentUser { id, name, images (type: "profile") { url } } }';
  QueryOptions options = QueryOptions(document: gql(query), variables: const {});
  var result = await client.query(options);

  if (result.data == null) {
    if (result.hasException) {
      if (result.exception!.linkException!.runtimeType == HttpLinkServerException) {
        final exception = result.exception!.linkException! as HttpLinkServerException;
        if (exception.parsedResponse!.response["message"] == "Invalid authentication token") {
          log.warning("Invalid authentication token. Forcing reauthentication");
          ref.invalidate(oAuthTokenProvider);
          // Clear GraphQL cache too
          client.resetStore(refetchQueries: false);
        }
      }
      log.warning("Unable to fetch data due to exception");
      throw result.exception!;
    }
    log.warning("Unable to fetch data but no exception triggered");
    log.info(result);
    throw Exception("Unable to fetch tournament data");
  }

  String? profileURL;
  if (result.data!['currentUser']['images'].length > 0) {
    profileURL = result.data!['currentUser']['images'][0]['url'];
  }
  var currentUser = User(result.data!['currentUser']['id'], result.data!['currentUser']['name'], profileURL);

  // One query to select all the information we need about upcoming events, etc
  // TODO: Pagination
  query =
      r'query user($userId: ID!, $filter: UserTournamentsPaginationFilter!, $sortBy: String!) { currentUser { id, tournaments(query: { filter: $filter, sortBy: $sortBy } ) { nodes { id, addrState, city, countryCode, slug, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, numEntrants, slug, userEntrant(userId: $userId) { id } videogame { id, name, displayName, images(type: "primary") { id, type, url } } } } } } }';
  options = QueryOptions(document: gql(query), variables: {'userId': currentUser.id, "filter": filter, "sortBy": sortBy});
  result = await client.query(options);

  if (result.data == null) {
    log.warning("Unable to fetch tournament data");
    log.info(result);
    throw Exception("Unable to fetch tournament data");
  }

  List<Tournament> data = [];
  for (var tournament in result.data!['currentUser']['tournaments']['nodes']) {
    // Create tournament object to begin with
    var tournamentObj = Tournament(tournament['id'], tournament['name'], DateTime.fromMillisecondsSinceEpoch(tournament['startAt'] * 1000));
    tournamentObj.city = tournament['city'];
    tournamentObj.slug = tournament['slug'];
    // Loop over events
    for (var event in tournament['events']) {
      // Create a videogame for this event
      // TODO: Reuse videogame objects
      var videogame = VideoGame(event['videogame']['id'], event['videogame']['name'], event['videogame']['images'][0]['url']);

      // Create event
      var eventObj = Event(event['id'], event['name'], videogame, DateTime.fromMillisecondsSinceEpoch(event['startAt'] * 1000), event['numEntrants']);
      eventObj.slug = event['slug'];
      eventObj.tournament = tournamentObj;
      tournamentObj.events.add(eventObj);

      // If we are participating, add it to our participating events list so we can later determine if we're registered for this event
      if (event['userEntrant'] != null) {
        currentUser.upcomingEvents.add(event['id']);
      }
    }
    // Loop over images
    for (var image in tournament['images']) {
      if (image['type'] == "banner") {
        tournamentObj.imageURL = image['url'];
      }
    }
    data.add(tournamentObj);
  }

  log.fine("Tournament data fetched successfully");
  return data;
}
