import 'package:flutter/material.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/event.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:start_gg_app/videogame.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(const MyApp());
}

class StartGGOAuth2Client extends OAuth2Client {
  // https://developer.start.gg/docs/oauth/oauth-overview
  StartGGOAuth2Client(
      {required String redirectUri, required String customUriScheme})
      : super(
            authorizeUrl: 'https://start.gg/oauth/authorize',
            tokenUrl:
                'https://api.start.gg/oauth/refresh', //Your service access token url
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

  MyAppState() {
    configureOauth();
    notifyListeners();
  }

  void updateTournaments({bool force = false}) {
    if (force ||
        DateTime.now()
                .subtract(const Duration(minutes: 5))
                .compareTo(lastTournamentSync) >
            0) {
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
      cache: GraphQLCache(
      ),
    );

    // One query to select all the information we need about upcoming events, etc
    // TODO: Pagination
    var query = r'query user { currentUser { tournaments(query: { filter: { upcoming: true, } } ) { nodes { id, addrState, city, countryCode, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType, events { id, name, startAt, state, videogame { id, name, displayName } } } } } }';
    QueryOptions options = QueryOptions(
        document: gql(query), variables: {});
    var result = await client.query(options);

    if (result.data == null) {
      return;
    }

    upcomingTournaments = [];
    for (var tournament in result.data!['currentUser']['tournaments']['nodes']) {
      // Create tournament object to begin with
      var tournamentObj = Tournament(tournament['id'], tournament['name'], tournament['city']);
      // Loop over events
      for (var event in tournament['events']) {
        // Create a videogame for this event
        // TODO: Reuse videogame objects
        var videogame = VideoGame(event['videogame']['id'], event['videogame']['name']);

        // Create event
        var eventObj = Event(event['id'], event['name'], videogame, DateTime.fromMillisecondsSinceEpoch(event['startAt'] * 1000));
        eventObj.tournament = tournamentObj;
        tournamentObj.events.add(eventObj);
      }
      upcomingTournaments.add(tournamentObj);
    }
    notifyListeners();
    
    return;

/*
    var userData = result.data!['currentUser'];

    // Get all the tournaments associated with this user
    // TODO: Is this previous, past, or both tournaments?
    // TODO: Pagination
    query =
        r'query user($userId: ID!) { user(id: $userId) { id, events { nodes { id, name, startAt, state, tournament{ id, addrState, city, countryCode, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType }, videogame { id, name, displayName } } } } }';
    options = QueryOptions(
        document: gql(query), variables: {'userId': userData['id']});
    result = await client.query(options);

    // Begin by clearing our existing tournaments (but don't notify yet, since we don't want the UI to bug out!)
    registeredEvents = [];

    // Loop over our events to create a list of tournaments
    // TOOD: We really want most screens to show events, not just tournaments, since they're the unit we care about most
    for (var event in result.data!['user']['events']['nodes']) {
      debugPrint("processing event");

      // Begin by creating a new VideoGame object
      // TODO: We should share videogame objects between events
      var videogame = VideoGame(
        event['videogame']['id'],
        event['videogame']['name'],
      );

      // TODO: Find a real placeholder image
      var imageURL =
          "https://images.start.gg/images/tournament/599117/image-00444799c9badea9a5e1ad6a1e6aae20-optimized.png"; // Placeholder
      for (var image in event['tournament']['images']) {
        if (image['type'] == "profile") {
          imageURL = image['url'];
        }
      }
      var tournament = Tournament(
          event['tournament']['id'], event['tournament']['name'], imageURL, event['tournament']['city']);
      
      var eventObj = Event(event['id'], event['name'], videogame, DateTime.fromMillisecondsSinceEpoch(event['startAt'] * 1000), tournament);
      registeredEvents.add(eventObj);
    }

    notifyListeners();
    debugPrint("graphql completed");
    */
  }

  void configureOauth() {
    StartGGOAuth2Client client = StartGGOAuth2Client(
      customUriScheme:
          'https', //Must correspond to the AndroidManifest's "android:scheme" attribute
      redirectUri:
          'https://startgg.ss23.geek.nz/oauth-callback', //Can be any URI, but the scheme part must correspond to the customeUriScheme
    );

    oauth2Helper = OAuth2Helper(client,
        grantType: OAuth2Helper.authorizationCode,
        clientId: '55',
        clientSecret:
            'd620f0c7911794528a592cf0e0f4c4dbff032626c121427aca6fa8f25a57bca6',
        scopes: ['user.identity']);

    updateAccessToken();
  }

  void updateAccessToken() async {
    try {
      var token = await oauth2Helper.getToken();
      if (token != null && token.accessToken != null) {
        accessToken = token.accessToken!;
        notifyListeners();
      }
    } catch (ex) {
      // TODO: Notify the user authentication failed and offer to attempt again
    }
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
                      return ListTile(
                        leading: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: appState.upcomingTournaments[i].imageURL ?? 'https://images.start.gg/images/tournament/599117/image-00444799c9badea9a5e1ad6a1e6aae20-optimized.png',
                        ),
                        title: Text(
                          appState.upcomingTournaments[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          children: [
                            Row(children: [Text(appState.upcomingTournaments[i].name)]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              Text(DateFormat('yyyy-MM-dd – kk:mm').format(DateTime(2002))),
                              Text(appState.upcomingTournaments[i].city ?? ''),
                            ]),
                        ]),
                        isThreeLine: true,
                        minLeadingWidth: 0,
                      );
                    }),
              ),
            ),
          ],
        );
  }
}
