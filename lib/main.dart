import 'package:flutter/material.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(MyApp());
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
        child: MaterialApp(home: MyHomePage(), title: "Start_gg_app"));
  }
}

class MyAppState extends ChangeNotifier {
  // TODO: Storage of tournaments, not just loading fresh every time
  var registeredTournaments = <Tournament>[];
  var lastTournamentSync =
      DateTime.utc(2000, 01, 01); // Sentinal for "never synced"
  late OAuth2Helper oauth2Helper;
  String accessToken = "";

  MyAppState() {
    addTournament();
    configureOauth();
    notifyListeners();
  }

  void addTournament() {
    registeredTournaments.add(Tournament(1, "foo",
        "https://images.start.gg/images/tournament/599117/image-00444799c9badea9a5e1ad6a1e6aae20-optimized.png"));
    registeredTournaments.add(Tournament(2, "popoff",
        "https://images.start.gg/images/tournament/599117/image-00444799c9badea9a5e1ad6a1e6aae20-optimized.png"));
    registeredTournaments.add(Tournament(3, "booper",
        "https://images.start.gg/images/tournament/599117/image-00444799c9badea9a5e1ad6a1e6aae20-optimized.png"));
    registeredTournaments.add(Tournament(4, "a",
        "https://images.start.gg/images/tournament/599117/image-00444799c9badea9a5e1ad6a1e6aae20-optimized.png"));
  }

  void updateTournaments({bool force = false}) {
    if (force ||
        DateTime.now()
                .subtract(const Duration(minutes: 5))
                .compareTo(lastTournamentSync) >
            0) {
      print("Should sync!");
      updateTournamentsForReal();
    } else {
      print("Skipping sync");
    }
  }

  Future<void> updateTournamentsForReal() async {
    await initHiveForFlutter();

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
      cache: GraphQLCache(store: HiveStore()),
    );

    QueryOptions options = QueryOptions(
        document: gql("query user { currentUser { id } }"), variables: {});
    var result = await client.query(options);

    if (result.data == null) {
      return;
    }

    var userData = result.data!['currentUser'];

    // Get all the tournaments associated with this user
    // TODO: Is this previous, past, or both tournaments?
    // TODO: Pagination
    var query =
        r'query user($userId: ID!) { user(id: $userId) { id, events { nodes { id, name, startAt, state, tournament{ id, addrState, city, countryCode, createdAt, endAt, images { id, height, ratio, type, url, width }, lat, lng, name, numAttendees, postalCode, startAt, state, tournamentType } } } } }';
    options = QueryOptions(
        document: gql(query), variables: {'userId': userData['id']});
    result = await client.query(options);

    // Begin by clearing our existing tournaments (but don't notify yet, since we don't want the UI to bug out!)
    registeredTournaments = [];

    // Loop over our events to create a list of tournaments
    // TOOD: We really want most screens to show events, not just tournaments, since they're the unit we care about most
    for (var event in result.data!['user']['events']['nodes']) {
      print("processing event");
      // TODO: Find a real placeholder image
      var imageURL =
          "https://images.start.gg/images/tournament/599117/image-00444799c9badea9a5e1ad6a1e6aae20-optimized.png"; // Placeholder
      for (var image in event['tournament']['images']) {
        if (image['type'] == "profile") {
          imageURL = image['url'];
        }
      }
      var tournament = Tournament(
          event['tournament']['id'], event['tournament']['name'], imageURL);
      registeredTournaments.add(tournament);
    }

    notifyListeners();
    print("graphql completed");
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
            CircularProgressIndicator(),
            Padding(
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
        page = TournamentPage();
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
          indicatorColor: Colors.amber[800],
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.sports_esports),
              label: 'Active Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'Past Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Find an Event',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(child: page),
        ),
      );
    });
  }
}

class TournamentPage extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    final headerStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // TODO: There is image popin even with the transparent image used here. Fix this.

    return SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Events', style: headerStyle),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: appState.updateTournamentsForReal,
                child: ListView.builder(
                    itemCount: appState.registeredTournaments.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        leading: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: appState.registeredTournaments[i].imageURL,
                        ),
                        title: Text(appState.registeredTournaments[i].name),
                        subtitle: Text('SSBU\nDate\nLocation'),
                        isThreeLine: true,
                        minLeadingWidth: 0,
                      );
                    }),
              ),
            ),
          ],
        ));
  }
}
