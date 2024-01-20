import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/startgg/event.dart';

part 'bracket_event_controller.g.dart';

@riverpod
Future<Event> fetchBracketEvent(FetchBracketEventRef ref, {required String eventId}) async {
  final log = Logger('fetchBracketEvent');

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  const query =
      r'query event($eventId: ID!) { event(id: $eventId) { id name tournament { id name images { id type url } } phases { id state bracketType groupCount isExhibition name numSeeds phaseOrder } } }';
  final options = QueryOptions(document: gql(query), variables: {'eventId': eventId});
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

  final event = Event.fromJson(result.data!['event']);

  // TODO: Should we do extra steps like sorting the phases?
  return event;
}
