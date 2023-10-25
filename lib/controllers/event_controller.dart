import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/event.dart';
import 'package:start_gg_app/helpers/graphql.dart';
import 'package:start_gg_app/helpers/oauth.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:start_gg_app/user.dart';
import 'package:start_gg_app/videogame.dart';

class EventController extends ChangeNotifier {
  List<Event> _data = [];
  DataState state = DataState.uninitialized;
  dynamic filter;
  String? sortBy;
  final log = Logger('EventController');

  EventController({required context, this.filter, this.sortBy}) {
    fetch(context);
  }

  List<Event> get data {
    return _data;
  }

  // TODO: Support paginated results with lazy loading!
  int get length => _data.length;

  Event operator [](int index) {
    return _data[index];
  }

  void fetch(BuildContext context) async {
    log.fine("Fetching event data");

    state = DataState.fetching;
    // Using `watch` here might result in rebuilds we don't need
    // TODO: Should we do something other than `watch` here?
    final oauth = Provider.of<OAuthToken>(context, listen: false);
    final accessToken = oauth.client!.credentials.accessToken;

    GraphQLHelper.accessToken = accessToken;
    final client = await GraphQLHelper().client;

    // Begin by getting our clients ID
    // TODO: Migrate the collection of user data to another place and just let this access it, since lots of places will need to display information about the current user
    var query = r'query user { currentUser { id, name, images (type: "profile") { url } } }';
    QueryOptions options = QueryOptions(document: gql(query), variables: const {});
    var result = await client.query(options);

    if (result.data == null) {
      log.warning("Unable to fetch user data");
      log.info(result);
      return;
    }

    String? profileURL;
    if (result.data!['currentUser']['images'].length > 0) {
      profileURL = result.data!['currentUser']['images'][0]['url'];
    }
    var currentUser = User(result.data!['currentUser']['id'], result.data!['currentUser']['name'], profileURL);

    // One query to select all the information we need about upcoming events, etc
    // TODO: Pagination

    query =
        r'query user($userId: ID!, $filter: UserTournamentsPaginationFilter!) { currentUser { id, tournaments(query: { filter: $filter } ) { nodes { id, addrState, city, countryCode, slug, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, numEntrants, slug, userEntrant(userId: $userId) { id } videogame { id, name, displayName, images(type: "primary") { id, type, url } } } } } } }';
    options = QueryOptions(document: gql(query), variables: {'userId': currentUser.id, "filter": filter});
    result = await client.query(options);

    if (result.data == null) {
      log.warning("Unable to fetch tournament data");
      log.info(result);
      return;
    }

    _data = [];
    for (var event in result.data!['currentUser']['tournaments']['nodes']) {
    }
    state = DataState.fetched;
    notifyListeners();
    log.fine("Tournament data fetched successfully");
  }
}
