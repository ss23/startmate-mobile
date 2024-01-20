import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/startgg/set.dart';

part 'bracket_set_controller.g.dart';

@riverpod
Future<List<Set>> fetchBracketSet(FetchBracketSetRef ref, {required String phaseGroupId}) async {
  final log = Logger('fetchBracketSet');

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  // TODO: Verify that a perPage of 250 is fine for this
  const query = r'query sets($phaseGroupId: ID!) { phaseGroup(id: $phaseGroupId) { sets(perPage: 250) { pageInfo { totalPages } nodes { id completedAt createdAt fullRoundText hasPlaceholder identifier lPlacement round setGamesType startAt startedAt state totalGames vodUrl wPlacement winnerId slots { id prereqId prereqPlacement prereqType slotIndex entrant { id name initialSeedNum isDisqualified skill } } } } } }';
  final options = QueryOptions(document: gql(query), variables: {'phaseGroupId': phaseGroupId});
  final result = await client.query(options);

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
    throw Exception('Unable to fetch event data');
  }

  if (result.data!['phaseGroup']['sets']['pageInfo']['totalPages'] > 1) {
    log.warning("Too many pages when loading sets! ${result.data!['phaseGroup']['sets']['pageInfo']['totalPages']} pages, but only got one");
  }

  final data = <Set>[];

  for (final phaseGroup in result.data!['phaseGroup']['sets']['nodes']) {
    data.add(Set.fromJson(phaseGroup));
  }

  return data;
}
