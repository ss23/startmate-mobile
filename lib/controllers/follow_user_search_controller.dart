
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/user.dart';
import 'package:http/http.dart' as http;

class FollowUserSearchController extends ChangeNotifier {
  List<User> _data = [];
  DataState state = DataState.uninitialized;
  dynamic filter;
  final log = Logger('FollowUserSearchController');

  List<User> data() {
    return _data;
  }

  // TODO: Support paginated results with lazy loading!
  int get length => _data.length;

  User operator [](int index) {
    return _data[index];
  }

  void fetch(String search) async {
    log.fine("Fetching users from search");

    _data = [];
    state = DataState.fetching;
    notifyListeners();

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
      return;
    }

    dynamic result;
    try {
      result = jsonDecode(response.body);
    } catch (e) {
      log.warning("Unable to parse user search data as JSON");
      log.info(response.body);
      log.info(e);
      return;
    }

    for (var user in result['data']['players']['nodes']) {
      var imageURL = "";
      if (user['images'].isNotEmpty) {
        imageURL = user['images'][0]['url'];
      }
      var obj = User(user['user']['id'], user['gamerTag'], imageURL);
      _data.add(obj);
    }

    state = DataState.fetched;
    notifyListeners();
    log.fine("Tournament data fetched successfully");
  }
}