import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/models/startgg/tournament.dart';

part 'featured_tournament_controller.g.dart';

@riverpod
Future<List<Tournament>> fetchFeaturedTournaments(FetchFeaturedTournamentsRef ref, {required dynamic filter}) async {
  final log = Logger('fetchFeaturedTournaments');

  // We're using a different API to usual, so we can avoid all our oauth code, as well as our normal adaptors
  final queryParams = {
    'operationName': 'TournamentScroller',
    'variables': r'{"publicCache":true,"filter":{"staffPicks":true},"page":1,"perPage":15,"filter__hashed":"{\"staffPicks\":true}"}',
    'extensions': r'{"persistedQuery":{"version":1,"sha256Hash":"b3cc323bd14c6d0446090a950fd6c911b452213e1a9b38c1667043590dec33b0"}}',
  };
  final url = Uri.https('www.start.gg', '/api/-/gql-public', queryParams);
  log.fine('Fetching featured tournaments from $url');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    log.warning('Unable to fetch featured tournament data: ${response.body}');
    throw Exception('Unable to fetch featured tournament data');
  }

  dynamic result;
  try {
    result = jsonDecode(response.body);
  } catch (e) {
    log.warning('Unable to parse featured tournament data as JSON: ${response.body} - $e');
    rethrow;
  }

  final data = <Tournament>[];
  for (final tournament in result['data']['tournaments']['nodes']) {
    final tournamentObj = Tournament.fromJson(tournament);
    data.add(tournamentObj);
  }

  log.fine('Featured tournament data fetched successfully');

  return data;
}
