import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/startgg/user.dart';

part 'current_user_controller.g.dart';

@riverpod
Future<User> fetchCurrentUser(FetchCurrentUserRef ref) async {
  final log = Logger('fetchCurrentUser');

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  // Begin by getting our clients ID
  const query = 'query user { currentUser { id name images { id type url } player { id gamerTag prefix } } }';
  final options = QueryOptions(document: gql(query));
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
    throw Exception('Unable to fetch tournament data');
  }

  final currentUser = User.fromJson(result.data!['currentUser']);
  return currentUser;
}
