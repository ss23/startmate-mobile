import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/models/startgg/user.dart';
part 'follow_user_search_controller.g.dart';

@riverpod
Future<List<User>> fetchUsers(FetchUsersRef ref, dynamic search) async {
  final log = Logger('fetchUsers');
  log.fine('Fetching users from search');

  final escapedSearch = json.encode(search); // Escape for using in the query
  log.fine('Search string escaped to: $search');

  // One query to select all the information we need about upcoming events, etc
  // TODO: Pagination
  // We're using a different API to usual, so we can avoid all our oauth code, as well as our normal adaptors
  final queryParams = {
    'query': r'query user($query: PlayerQuery!) { players(query: $query) { nodes { id user { id name images { id type url } player { id prefix gamerTag } } } } }',
    'variables': '{"query":{"filter":{"searchField":$escapedSearch}}}',
  };
  final url = Uri.https('www.start.gg', '/api/-/gql-public', queryParams);
  final response = await http.get(url);

  if (response.statusCode != 200) {
    log.warning('Unable to perform user search');
    log.info(response.body);
    throw Exception('Unable to perform user search');
  }

  dynamic result;
  try {
    result = jsonDecode(response.body);
  } catch (e) {
    log.warning('Unable to parse user search data as JSON');
    log.info(response.body);
    log.info(e);
    rethrow;
  }

  final data = <User>[];

  for (final player in result['data']['players']['nodes']) {
    // For some reason, while we are fetching players, we cannot always link these to a user (privacy settings?)
    // As we only want to be able to show players here that we can follow, we can ignore any that aren't followable
    if (player['user'] == null) {
      log.fine('Skipped user with missing user ID: $player');
      continue;
    }

    final user = User.fromJson(player['user']);
    data.add(user);
  }

  log.fine('Tournament data fetched successfully');

  return data;
}
