import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:start_gg_app/event.dart';
import 'package:start_gg_app/screens/monolith.dart';
import 'package:start_gg_app/phase.dart';
import 'package:start_gg_app/phasegroup.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/set.dart';

class EventBracketPage extends StatefulWidget {
  const EventBracketPage({super.key, required this.event, required this.appState});

  final Event event;
  final MyAppState appState;

  @override
  State<EventBracketPage> createState() => _EventBracketPageState();
}

class _EventBracketPageState extends State<EventBracketPage> {
  var phases = <Phase>[];

  @override
  void initState() {
    super.initState();

    populateEventdata();
  }

  Future<void> refreshEventdata() async {
    setState(() {
      phases = [];
    });
    populateEventdata();
  }

  Future<void> populateEventdata() async {
    // We need to download all of the bracket data
    final HttpLink httpLink = HttpLink(
      'https://api.start.gg/gql/alpha',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer ${widget.appState.accessToken}',
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
        r'query EventOverviewPage($eventId: ID!) { event(id: $eventId) { phases { id name phaseGroups { pageInfo { totalPages } nodes {id displayIdentifier startAt sets { pageInfo { totalPages } nodes { id fullRoundText round slots { id entrant { name } } } } } } } } }';
    QueryOptions options = QueryOptions(document: gql(query), variables: {'eventId': widget.event.id});
    var result = await client.query(options);

    if (result.data == null) {
      print("No results found, or null, werid");
      return;
    }

    setState(() {
      for (var phase in result.data!['event']['phases']) {
        var phaseObj = Phase(phase['id'], phase['name']);

        for (var phaseGroup in phase['phaseGroups']['nodes']) {
          // displayName can sometimes become an integer. If so, we should cast it to a string properly
          var phaseGroupObj = PhaseGroup(phaseGroup['id'], phaseGroup['displayIdentifier']);
          phaseObj.phaseGroups.add(phaseGroupObj);
        }
        phases.add(phaseObj);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (phases.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Text("Loading bracket..."),
          ]),
        ),
      );
    }

    return DefaultTabController(
      initialIndex: 0,
      length: phases.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.event.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh bracket',
              onPressed: () {
                refreshEventdata();
              },
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              for (int i = 0; i < phases.length; i++)
                Tab(
                  text: phases[i].name,
                )
            ],
          ),
        ),
        body: TabBarView(
          children: [for (int i = 0; i < phases.length; i++) PhasePage(phase: phases[i])],
        ),
      ),
    );
  }
}

class PhasePage extends StatelessWidget {
  const PhasePage({super.key, required this.phase});

  final Phase phase;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    //return Center(child: Text("asdfasdfasdf"));
    return Column(children: [
      DefaultTabController(
        initialIndex: 0,
        length: phase.phaseGroups.length,
        child: TabBar.secondary(
          tabs: <Widget>[for (int i = 0; i < phase.phaseGroups.length; i++) Tab(text: "Pool ${phase.phaseGroups[i].displayIdentifier}")],
        ),
      ),
      Expanded(
        child: TabBarView(
          children: [for (int i = 0; i < phase.phaseGroups.length; i++) SetPage(phaseGroup: phase.phaseGroups[i])],
        ),
      ),
    ]);
  }
}

class SetPage extends StatefulWidget {
  const SetPage({super.key, required this.phaseGroup});

  final PhaseGroup phaseGroup;

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  List<GGSet>? sets;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getSetData();
  }

  Future<void> getSetData() async {
    var appState = context.watch<MyAppState>();

    // We need to download all of the bracket data
    final HttpLink httpLink = HttpLink(
      'https://api.start.gg/gql/alpha',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer ${appState.accessToken}',
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
        r'query GetGames($phaseGroupId: ID!, $page: Int) { phaseGroup(id: $phaseGroupId) { sets(page: $page, perPage: 100) { pageInfo { totalPages } nodes { id fullRoundText round identifier totalGames winnerId slots { entrant { id name } } games { winnerId } } } } }';
    // FIXME: This is just for testing!!!! Hardcoded ID needs to be changed
    //QueryOptions options = QueryOptions(document: gql(query), variables: {'phaseGroupId': 2244341, 'page': 1});
    QueryOptions options = QueryOptions(document: gql(query), variables: {'phaseGroupId': widget.phaseGroup.id, 'page': 1});
    var result = await client.query(options);

    if (result.data == null) {
      print("No results found, or null, werid");
      return;
    }

    if (result.data!['phaseGroup']['sets']['pageInfo']['totalPages'] > 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not fetch all bracket data! File a bug')));
      print("Warning! We are not getting all of the data! Fix me!!!!");
    }

    setState(() {
      sets = [];
      for (var set in result.data!['phaseGroup']['sets']['nodes']) {
        var setObj = GGSet(set['id']);
        setObj.fullRoundText = set['fullRoundText'];
        setObj.round = set['round'];
        setObj.identifier = set['identifier'];
        setObj.totalGames = set['totalGames'];
        setObj.winnerId = set['winnerId'];

        sets!.add(setObj);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (sets == null) {
      // We are still waiting for results, loading time!
      return const Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Text("Loading sets..."),
          ]),
        ),
      );
    }

    Map<int, List<GGSet>> winnersSetsByRound = {};
    Map<int, List<GGSet>> losersSetsByRound = {};

    for (var set in sets!) {
      if (set.round! > 0) {
        if (winnersSetsByRound[set.round] == null) {
          winnersSetsByRound[set.round!] = [];
        }
        winnersSetsByRound[set.round]!.add(set);
      } else {
        if (losersSetsByRound[set.round] == null) {
          losersSetsByRound[set.round!] = [];
        }
        losersSetsByRound[set.round]!.add(set);
      }
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (int i = 1; i <= winnersSetsByRound.length; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(winnersSetsByRound[i]![0].fullRoundText!, style: theme.textTheme.labelLarge),
                for (int j = 0; j < winnersSetsByRound[i]!.length; j++)
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1, color: const Color(0xFFDDDDDD)),
                                //borderRadius: BorderRadius.circular(3),
                              ),
                              padding: const EdgeInsets.only(left: 14.0, right: 8.0, top: 1.0, bottom: 1.0),
                              child: const Text("player 1sadf lkasndf laskfn asldfkn asldfkn asldfk n", overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              width: 200,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                                  right: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                                  bottom: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                                ),
                              ),
                              padding: const EdgeInsets.only(left: 14.0, right: 8.0, top: 1.0, bottom: 1.0),
                              child: const Text("player 2", overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: Container(
                            padding: const EdgeInsets.only(left: 8.0, right: 18.0),
                            decoration: const BoxDecoration(
                              // TODO: This Border Radius looks silly, make it nicer (hard edges probably, more like an arrow)
                              borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                              color: Colors.blue,
                            ),
                            child: Text(winnersSetsByRound[i]![j].identifier!, style: theme.textTheme.labelLarge!.merge(const TextStyle(color: Colors.white)))),
                      ),
                    ],
                  ),
                Text(losersSetsByRound[(2 - losersSetsByRound.length - i)]![0].fullRoundText!, style: theme.textTheme.labelLarge),
                for (int j = 0; j < winnersSetsByRound[i]!.length; j++)
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1, color: const Color(0xFFDDDDDD)),
                                //borderRadius: BorderRadius.circular(3),
                              ),
                              padding: const EdgeInsets.only(left: 14.0, right: 8.0, top: 1.0, bottom: 1.0),
                              child: const Text("player 1sadf lkasndf laskfn asldfkn asldfkn asldfk n", overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              width: 200,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                                  right: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                                  bottom: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                                ),
                              ),
                              padding: const EdgeInsets.only(left: 14.0, right: 8.0, top: 1.0, bottom: 1.0),
                              child: const Text("player 2", overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: Container(
                            padding: const EdgeInsets.only(left: 8.0, right: 18.0),
                            decoration: const BoxDecoration(
                              // TODO: This Border Radius looks silly, make it nicer (hard edges probably, more like an arrow)
                              borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                              color: Colors.blue,
                            ),
                            child: Text(winnersSetsByRound[i]![j].identifier!, style: theme.textTheme.labelLarge!.merge(const TextStyle(color: Colors.white)))),
                      ),
                    ],
                  )
              ],
            ),
          ),
      ],
    );
  }
}
