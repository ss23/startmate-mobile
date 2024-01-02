import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/controllers/followed_users_controller.dart';
import 'package:start_gg_app/event.dart';
import 'package:start_gg_app/helpers/graphql.dart';
import 'package:start_gg_app/helpers/oauth.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:start_gg_app/videogame.dart';

class FollowedTournamentController extends ChangeNotifier {
  List<Tournament> _data = [];
  DataState state = DataState.uninitialized;
  List<int> userIds = [];
  dynamic filter;
  final log = Logger('FollowedTournamentController');

  FollowedTournamentController({required context, required this.filter}) {
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

  void update(BuildContext context, FollowedUsersController followedUsersController) {
    log.fine("Updated userIds");
    userIds = followedUsersController.data().map((user) => user.user.id!).toList();
    fetch(context);
  }

  void fetch(BuildContext context) async {
    log.fine("Fetching followed tournament data");

    if (userIds.isEmpty) {
      _data = [];
      state = DataState.fetched;
      notifyListeners();
      log.fine("No followed users");
      return;
    }

    // TODO: Implement a faster version of fetching for the case where all that has changed is one less userId is in the list.
    //       For this case, we don't need to fetch every result again, but just remove tournaments which are here due to the user alone.

    state = DataState.fetching;
    notifyListeners();
    
    final oauth = Provider.of<OAuthToken>(context, listen: false);
    final accessToken = oauth.client!.credentials.accessToken;

    GraphQLHelper.accessToken = accessToken;
    final client = await GraphQLHelper().client;

    _data = [];
    for (var userId in userIds) {
      // One query to select all the information we need about upcoming events, etc
      // TODO: Pagination
      var query =
          r'query user($userId: ID!, $filter: UserTournamentsPaginationFilter!) { user(id: $userId) { tournaments(query: { filter: $filter } ) { nodes { id, addrState, city, countryCode, slug, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, numEntrants, slug, videogame { id, name, displayName, images(type: "primary") { id, type, url } } } } } } }';
      var options = QueryOptions(document: gql(query), variables: {'userId': userId, "filter": filter});
      var result = await client.query(options);

      if (result.data == null) {
        if (result.hasException && result.exception!.linkException!.runtimeType == HttpLinkServerException) {
          final exception = result.exception!.linkException! as HttpLinkServerException;
          if (exception.parsedResponse!.response["message"] == "Invalid authentication token") {
            log.warning("Invalid authentication token. Forcing reauthentication");
            oauth.reauthenticate();
            // Clear GraphQL cache too
            client.resetStore(refetchQueries: false);
            return;
          }
        }
        log.warning("Unable to fetch data");
        log.info(result);
        return;
      }

      if (result.data == null || result.data!['user'] == null) {
        log.warning("Unable to fetch tournament data for user ($userId)");
        log.info(result);
        continue;
      }

      if (result.data!['user']['tournaments'] == null) {
        log.finer("Skipping user ($userId) with no upcoming tournaments");
        continue;
      }

      for (var tournament in result.data!['user']['tournaments']['nodes']) {
        // Perform deduplication here
        if (_data.where((t) => t.id == tournament['id']).isNotEmpty) {
          continue;
        }

        // Create tournament object to begin with
        var tournamentObj = Tournament(tournament['id'], tournament['name'], DateTime.fromMillisecondsSinceEpoch(tournament['startAt'] * 1000));
        tournamentObj.city = tournament['city'];
        tournamentObj.slug = tournament['slug'];
        // Loop over events
        for (var event in tournament['events']) {
          // Create a videogame for this event
          // TODO: Reuse videogame objects
          var videogame = VideoGame(event['videogame']['id'], event['videogame']['name'], event['videogame']['images'][0]['url']);

          // Create event
          var eventObj = Event(event['id'], event['name'], videogame, DateTime.fromMillisecondsSinceEpoch(event['startAt'] * 1000), event['numEntrants']);
          eventObj.slug = event['slug'];
          eventObj.tournament = tournamentObj;
          tournamentObj.events.add(eventObj);

          // If we are participating, add it to our participating events list so we can later determine if we're registered for this event
        }
        // Loop over images
        for (var image in tournament['images']) {
          if (image['type'] == "banner") {
            tournamentObj.imageURL = image['url'];
          }
        }
        _data.add(tournamentObj);
      }
    }

    // Sort the data
    _data.sort((a, b) => a.startAt.compareTo(b.startAt));

    state = DataState.fetched;
    notifyListeners();
    log.fine("Tournament data fetched successfully");
  }
}
