import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/controllers/followed_users_controller.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/startgg/tournament.dart';

part 'followed_tournament_controller.g.dart';

@riverpod
Future<List<Tournament>> fetchFollowedTournaments(FetchFollowedTournamentsRef ref, dynamic filter) async {
  final log = Logger('fetchFollowedTournaments');
  log.fine('Fetching followed tournament data');

  final followedUsers = await ref.watch(followedUsersProvider.future);

  if (followedUsers.isEmpty) {
    log.fine('No followed users');
    return [];
  }

  // TODO: Implement a faster version of fetching for the case where all that has changed is one less userId is in the list.
  //       For this case, we don't need to fetch every result again, but just remove tournaments which are here due to the user alone.

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  final data = <Tournament>[];
  for (final followedUser in followedUsers) {
    final userId = followedUser.user.id;
    // One query to select all the information we need about upcoming events, etc
    // TODO: Pagination
    const query =
        r'query user($userId: ID!, $filter: UserTournamentsPaginationFilter!) { user(id: $userId) { tournaments(query: { filter: $filter } ) { nodes { id, addrState, city, countryCode, slug, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, numEntrants, slug, videogame { id, name, displayName, images(type: "primary") { id, type, url } } } } } } }';
    final options = QueryOptions(document: gql(query), variables: {'userId': userId, 'filter': filter});
    final result = await client.query(options);

    if (result.data == null) {
      if (result.hasException) {
        if (result.exception!.linkException!.runtimeType == HttpLinkServerException) {
          final exception = result.exception!.linkException! as HttpLinkServerException;
          if (exception.parsedResponse!.response['message'] == 'Invalid authentication token') {
            log.warning('Invalid authentication token. Forcing reauthentication');
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
      throw Exception('Unable to fetch followed tournaments');
    }

    if (result.data == null || result.data!['user'] == null) {
      log.warning('Unable to fetch tournament data for user ($userId)');
      log.info(result);
      continue;
    }

    if (result.data!['user']['tournaments'] == null) {
      log.finer('Skipping user ($userId) with no upcoming tournaments');
      continue;
    }

    for (final tournament in result.data!['user']['tournaments']['nodes']) {
      // Perform deduplication here
      if (data.where((t) => t.id == tournament['id']).isNotEmpty) {
        continue;
      }

      final tournamentObj = Tournament.fromJson(tournament);
      data.add(tournamentObj);
    }
  }

  // Sort the data
  data.sort((a, b) => a.startAt!.compareTo(b.startAt!));

  return data;
}
