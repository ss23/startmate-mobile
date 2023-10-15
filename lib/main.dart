import 'package:flutter/material.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/event.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:start_gg_app/user.dart';
import 'package:start_gg_app/videogame.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class StartGGOAuth2Client extends OAuth2Client {
  // https://developer.start.gg/docs/oauth/oauth-overview
  StartGGOAuth2Client({required String redirectUri, required String customUriScheme})
      : super(
            authorizeUrl: 'https://start.gg/oauth/authorize',
            tokenUrl: 'https://api.start.gg/oauth/refresh', //Your service access token url
            redirectUri: redirectUri,
            customUriScheme: customUriScheme);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          home: const MyHomePage(),
          title: "Start_gg_app",
          theme: ThemeData(
            useMaterial3: true,
          ),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  // TODO: Storage of events, not just loading fresh every time
  var upcomingTournaments = <Tournament>[];
  var lastTournamentSync = DateTime.utc(2000, 01, 01); // Sentinal for "never synced"
  late OAuth2Helper oauth2Helper;
  String accessToken = "";
  User? currentUser;

  MyAppState() {
    configureOauth();
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
        r'query user($userId: ID!) { currentUser { id, tournaments(query: { filter: { upcoming: true, } } ) { nodes { id, addrState, city, countryCode, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, numEntrants, userEntrant(userId: $userId) { id } videogame { id, name, displayName, images(type: "primary") { id, type, url } } } } } } }';
    QueryOptions options = QueryOptions(document: gql(query), variables: {'userId': currentUser!.id});
    var result = await client.query(options);

    if (result.data == null) {
      return;
    }

    upcomingTournaments = [];
    for (var tournament in result.data!['currentUser']['tournaments']['nodes']) {
      // Create tournament object to begin with
      var tournamentObj = Tournament(tournament['id'], tournament['name'], tournament['city'], DateTime.fromMillisecondsSinceEpoch(tournament['startAt'] * 1000));
      // Loop over events
      for (var event in tournament['events']) {
        // Create a videogame for this event
        // TODO: Reuse videogame objects
        var videogame = VideoGame(event['videogame']['id'], event['videogame']['name'], event['videogame']['images'][0]['url']);

        // Create event
        var eventObj = Event(event['id'], event['name'], videogame, DateTime.fromMillisecondsSinceEpoch(event['startAt'] * 1000), event['numEntrants']);
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

  void configureOauth() {
    StartGGOAuth2Client client = StartGGOAuth2Client(
      customUriScheme: 'https', //Must correspond to the AndroidManifest's "android:scheme" attribute
      redirectUri: 'https://startgg.ss23.geek.nz/oauth-callback', //Can be any URI, but the scheme part must correspond to the customeUriScheme
    );

    oauth2Helper =
        OAuth2Helper(client, grantType: OAuth2Helper.authorizationCode, clientId: '55', clientSecret: 'd620f0c7911794528a592cf0e0f4c4dbff032626c121427aca6fa8f25a57bca6', scopes: ['user.identity']);

    updateAccessToken();
  }

  void updateAccessToken() async {
    //try {
      // Populate the currentUserId at the same time, which verifies our token is working

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
        var query =
            r'query user { currentUser { id, name, images (type: "profile") { url } } }';
        QueryOptions options = QueryOptions(document: gql(query), variables: {});
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
  }

  bool isAccessTokenValid() {
    // TODO: Do this properly
    return (accessToken != "");
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // If we haven't finished setting up our state, we should just show a loading bar
    var isLoading = false;
    var loadingReason = "";
    if (appState.accessToken == "") {
      loadingReason = "Waiting for start.gg";
      isLoading = true;
    }
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Text(loadingReason),
          ]),
        ),
      );
    }

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const TournamentPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.sports_esports),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Find',
            ),
          ],
        ),
        body: SafeArea(child: page),
      );
    });
  }
}

class TournamentPage extends StatelessWidget {
  const TournamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    // TODO: There is image popin even with the transparent image used here. Fix this.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0, top: 8.0),
          child: Text('Tournaments', style: theme.textTheme.labelMedium),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            onRefresh: appState.updateTournamentsForReal,
            child: ListView.builder(
                itemCount: appState.upcomingTournaments.length,
                itemBuilder: (BuildContext context, int i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            ),
                            child: Container(
                              height: 60,
                              child: FittedBox(
                                //alignment: Alignment.topCenter,
                                fit: BoxFit.fitWidth,
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: appState.upcomingTournaments[i].imageURL ?? 'https://images.start.gg/images/tournament/599117/image-a8543c0cc170271d6caf8df258650fec-optimized.png',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    appState.upcomingTournaments[i].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                ),
                                Icon(Icons.more_vert)
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month),
                                  Text(DateFormat('yyyy-MM-dd – kk:mm').format(appState.upcomingTournaments[i].startAt ?? DateTime(0000))),
                                ],
                              )),
                          Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on),
                                  Text(appState.upcomingTournaments[i].city),
                                ],
                              )),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                            child: Column(children: [
                              for (int j = 0; j < appState.upcomingTournaments[i].events.length; j++)
                                Column(
                                  children: [
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Container(
                                        height: 120,
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: appState.upcomingTournaments[i].events[j].videogame.imageURL ??
                                              'https://images.start.gg/images/videogame/9352/image-652433aa40f80e55d076647313d6bb14-optimized.jpg',
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    appState.upcomingTournaments[i].events[j].name,
                                                    style: theme.textTheme.headlineSmall,
                                                  ),
                                                  // TODO: Use a different icon/interaction if we haven't registered for this event
                                                  if (appState.currentUser!.upcomingEvents.contains(appState.upcomingTournaments[i].events[j].id))
                                                    Icon(Icons.check_circle_outline, color: Colors.green)
                                                ],
                                              ),
                                              Text(appState.upcomingTournaments[i].events[j].videogame.name),
                                              Text('${appState.upcomingTournaments[i].events[j].numEntrants} entrants'),
                                              FilledButton(
                                                // TODO: Take us to the bracket view page
                                                onPressed: () {},
                                                child: Text("Bracket"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                    if (j != (appState.upcomingTournaments[i].events.length - 1)) Divider()
                                  ],
                                ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
