import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/startgg/user.dart';

part 'user_registered_controller.g.dart';

@riverpod
Future<List<User>> fetchRegisteredUsers(FetchRegisteredUsersRef ref, {required String id}) async {
  final log = Logger('fetchRegisteredUsers');
  log.fine('Fetching registered users for tournament $id');

  // Unfortunately, there doesn't seem to be a way to see which users are attending a tournament from the API
  // Instead, we are going to fetch the maximum number of participants and hope the information we need is in there
  // TODO: Is there a better way to do this?

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  // TODO: Pagination over all participants, not just the first 500
  const query = r'query tournament($tournamentId: ID!) { tournament(id: $tournamentId) { id participants(query: {perPage: 500}) { nodes { user { id name images { id type url } player { id gamerTag prefix } } } } } }';
  final options = QueryOptions(document: gql(query), variables: {'tournamentId': id});
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
    throw Exception('Unable to fetch tournament data');
  }

  final data = <User>[];

  for (final participant in result.data!['tournament']['participants']['nodes']) {
    // We are checking whether there's a user object attached to this participant, just in case some of them are missing
    if (participant['user'] == null) {
      continue;
    }
    data.add(User.fromJson(participant['user']));
  }

  log.info(data);

  return data;
}
