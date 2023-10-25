import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:http/http.dart' as http;

class FeaturedTournamentController extends ChangeNotifier {
  List<Tournament> _data = [];
  DataState state = DataState.uninitialized;
  dynamic filter;
  String? sortBy;
  final log = Logger('FeaturedTournamentController');

  FeaturedTournamentController({required context, this.filter}) {
    fetch(context);
  }

  List<Tournament> data() {
    return _data;
  }

  // TODO: Support paginated results with lazy loading!
  int get length => _data.length;

  Tournament operator [](int index) {
    return _data[index];
  }

  void fetch(BuildContext context) async {
    log.fine("Fetching featured tournament data");

    state = DataState.fetching;

    // We're using a different API to usual, so we can avoid all our oauth code, as well as our normal adaptors
    final queryParams = {
      "operationName": "TournamentScroller",
      "variables": r'{"publicCache":true,"filter":{"staffPicks":true},"page":1,"perPage":15,"filter__hashed":"{\"staffPicks\":true}"}',
      "extensions": r'{"persistedQuery":{"version":1,"sha256Hash":"b3cc323bd14c6d0446090a950fd6c911b452213e1a9b38c1667043590dec33b0"}}',
    };
    final url = Uri.https('www.start.gg', '/api/-/gql-public', queryParams);
    log.fine("Fetching featured tournaments from $url");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      log.warning("Unable to fetch featured tournament data");
      log.info(response.body);
      return;
    }

    dynamic result;
    try {
      result = jsonDecode(response.body);
    } catch (e) {
      log.warning("Unable to parse featured tournament data as JSON");
      log.info(response.body);
      log.info(e);
      return;
    }

    _data = [];
    for (var tournament in result['data']['tournaments']['nodes']) {
      var tournamentObj = Tournament(tournament['id'], tournament['name'], DateTime.fromMillisecondsSinceEpoch(tournament['startAt'] * 1000));
      tournamentObj.imageURL = tournament['images'][1]['url'];
      tournamentObj.slug = tournament['slug'];
      tournamentObj.isOnline = tournament['isOnline'];
      tournamentObj.locationDisplayName = tournament['locationDisplayName'] ?? 'Online';
      _data.add(tournamentObj);
    }
    state = DataState.fetched;
    notifyListeners();
    log.fine("Featured tournament data fetched successfully");
  }
}
