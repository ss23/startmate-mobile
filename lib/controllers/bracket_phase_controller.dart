import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/startgg/phasegroup.dart';

part 'bracket_phase_controller.g.dart';

@riverpod
Future<List<PhaseGroup>> fetchBracketPhase(FetchBracketPhaseRef ref, {required String phaseId}) async {
  final log = Logger('fetchBracketEvent');

  final accessToken = ref.watch(oAuthTokenProvider).requireValue;

  GraphQLHelper.accessToken = accessToken;
  final client = await GraphQLHelper().client;

  const query =
      r'query phase($phaseId: ID!) { phase(id: $phaseId) { phaseGroups { nodes { id bracketType bracketUrl displayIdentifier firstRoundTime numRounds startAt state } } } } ';
  final options = QueryOptions(document: gql(query), variables: {'phaseId': phaseId});
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


  final data = <PhaseGroup>[];

  for (final phaseGroup in result.data!['phase']['phaseGroups']['nodes']) {
    data.add(PhaseGroup.fromJson(phaseGroup));
  }

  return data;
}
