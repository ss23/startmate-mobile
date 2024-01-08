import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/startgg/tournament.dart';
import 'package:startmate/models/startgg/user.dart';

part 'tournament_controller.g.dart';

@riverpod
Future<List<Tournament>> fetchTournaments(FetchTournamentsRef ref, {required dynamic filter, String sortBy = 'tournament.startAt desc'}) async {
  final log = Logger('fetchTournaments');
  log.fine('Fetching tournament data');

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  // Begin by getting our clients ID
  var query = r'query user { currentUser { id name images { id type url } player { id gamerTag prefix } } }';
  var options = QueryOptions(document: gql(query));
  var result = await client.query(options);

  if (result.data == null) {
    if (result.hasException) {
      if (result.exception!.linkException!.runtimeType == HttpLinkServerException) {
        final exception = result.exception!.linkException! as HttpLinkServerException;
        if (exception.parsedResponse!.response['message'] == 'Invalid authentication token') {
          log.warning('Invalid authentication token. Forcing reauthentication');
          await ref.read(oAuthTokenProvider.notifier).forceReset();
          ref.invalidate(oAuthTokenProvider);
          // Clear GraphQL cache too
          await client.resetStore(refetchQueries: false);
        }
      }
      log.warning('Unable to fetch data due to exception');
      throw result.exception!;
    }
    log.warning('Unable to fetch data but no exception triggered');
    log.info(result);
    throw Exception('Unable to fetch tournament data');
  }

  final currentUser = User.fromJson(result.data!['currentUser']);

  // One query to select all the information we need about upcoming events, etc
  // TODO: Pagination
  query =
      r'query user($userId: ID!, $filter: UserTournamentsPaginationFilter!, $sortBy: String!) { currentUser { tournaments(query: { filter: $filter, sortBy: $sortBy } ) { nodes { id, addrState, city, countryCode, slug, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, numEntrants, slug, userEntrant(userId: $userId) { id } videogame { id, name, displayName, images(type: "primary") { id, type, url } } } } } } }';
  options = QueryOptions(document: gql(query), variables: {'userId': currentUser.id, 'filter': filter, 'sortBy': sortBy});
  result = await client.query(options);

  if (result.data == null) {
    log.warning('Unable to fetch tournament data');
    log.info(result);
    throw Exception('Unable to fetch tournament data');
  }

  final data = <Tournament>[];
  for (final tournament in result.data!['currentUser']['tournaments']['nodes']) {
    final tournamentObj = Tournament.fromJson(tournament);
    data.add(tournamentObj);
  }

  log.fine('Tournament data fetched successfully');
  return data;
}
