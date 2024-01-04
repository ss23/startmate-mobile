import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startmate/user.dart';
import 'package:http/http.dart' as http;

part 'follow_user_search_controller.g.dart';

@riverpod
Future<List<User>> fetchUsers(FetchUsersRef ref, dynamic search) async {
  final log = Logger('fetchUsers');
  log.fine("Fetching users from search");

  search = json.encode(search); // Escape for using in the query
  log.fine("Search string escaped to: $search");

  // One query to select all the information we need about upcoming events, etc
  // TODO: Pagination
  // We're using a different API to usual, so we can avoid all our oauth code, as well as our normal adaptors
  final queryParams = {
    "query": r'query user($query: PlayerQuery!) { players(query: $query) { nodes { id name prefix gamerTag images(type: "profile") { id type url } user { id } } } }',
    "variables": '{"query":{"filter":{"searchField":$search}}}',
  };
  final url = Uri.https('www.start.gg', '/api/-/gql-public', queryParams);
  final response = await http.get(url);

  if (response.statusCode != 200) {
    log.warning("Unable to perform user search");
    log.info(response.body);
    throw Exception("Unable to perform user search");
  }

  dynamic result;
  try {
    result = jsonDecode(response.body);
  } catch (e) {
    log.warning("Unable to parse user search data as JSON");
    log.info(response.body);
    log.info(e);
    rethrow;
  }

  List<User> data = [];

  for (var user in result['data']['players']['nodes']) {
    var imageURL = "";
    if (user['images'].isNotEmpty) {
      imageURL = user['images'][0]['url'];
    }
    var obj = User(user['user']['id'], user['gamerTag'], imageURL);
    data.add(obj);
  }

  log.fine("Tournament data fetched successfully");

  return data;
}
