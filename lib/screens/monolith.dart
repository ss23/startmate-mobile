import 'package:flutter/material.dart';
import 'package:start_gg_app/event.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:start_gg_app/user.dart';
import 'package:start_gg_app/videogame.dart';

class MyAppState extends ChangeNotifier {
  // TODO: Storage of events, not just loading fresh every time
  var upcomingTournaments = <Tournament>[];
  var lastTournamentSync = DateTime.utc(2000, 01, 01); // Sentinel for "never synced"
  String accessToken = "";
  User? currentUser;

  MyAppState() {
    notifyListeners();
  }

  void updateTournaments({bool force = false}) {
    if (force || DateTime.now().subtract(const Duration(minutes: 5)).compareTo(lastTournamentSync) > 0) {
      debugPrint("Should sync!");
      updateTournamentsForReal();
    } else {
      debugPrint("Skipping sync");
    }
  }

  Future<void> updateTournamentsForReal() async {
    final HttpLink httpLink = HttpLink(
      'https://api.start.gg/gql/alpha',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $accessToken',
    );
    final Link link = authLink.concat(httpLink);

    GraphQLClient client = GraphQLClient(
      link: link,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(),
    );

    // One query to select all the information we need about upcoming events, etc
    // TODO: Pagination
    var query =
        r'query user($userId: ID!) { currentUser { id, tournaments(query: { filter: { upcoming: true, } } ) { nodes { id, addrState, city, countryCode, slug, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, numEntrants, slug, userEntrant(userId: $userId) { id } videogame { id, name, displayName, images(type: "primary") { id, type, url } } } } } } }';
    QueryOptions options = QueryOptions(document: gql(query), variables: {'userId': currentUser!.id});
    var result = await client.query(options);

    if (result.data == null) {
      return;
    }

    upcomingTournaments = [];
    for (var tournament in result.data!['currentUser']['tournaments']['nodes']) {
      // Create tournament object to begin with
      var tournamentObj = Tournament(tournament['id'], tournament['name'], tournament['city'], DateTime.fromMillisecondsSinceEpoch(tournament['startAt'] * 1000));
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
        if (event['userEntrant'] != null) {
          currentUser!.upcomingEvents.add(event['id']);
        }
      }
      upcomingTournaments.add(tournamentObj);
    }
    notifyListeners();
  }

  void updateAccessToken() async {
    //try {
    // Populate the currentUserId at the same time, which verifies our token is working
    /*
    var token = await oauth2Helper.getToken();
    if (token != null && token.accessToken != null) {
      accessToken = token.accessToken!;
      final HttpLink httpLink = HttpLink(
        'https://api.start.gg/gql/alpha',
      );

      final AuthLink authLink = AuthLink(
        getToken: () async => 'Bearer $accessToken',
      );
      final Link link = authLink.concat(httpLink);

      GraphQLClient client = GraphQLClient(
        link: link,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(),
      );

      // One query to select all the information we need about upcoming events, etc
      // TODO: Pagination
      var query = r'query user { currentUser { id, name, images (type: "profile") { url } } }';
      QueryOptions options = QueryOptions(document: gql(query), variables: const {});
      var result = await client.query(options);

      if (result.data == null) {
        return;
      }
      String? profileURL;
      if (result.data!['currentUser']['images'].length > 0) {
        profileURL = result.data!['currentUser']['images'][0]['url'];
      }
      currentUser = User(result.data!['currentUser']['id'], result.data!['currentUser']['name'], profileURL);
      notifyListeners();
    }
    //} catch (ex) {
    // TODO: Notify the user authentication failed and offer to attempt again
    //}
    */
  }

  bool isAccessTokenValid() {
    // TODO: Do this properly
    return (accessToken != "");
  }
}


