import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/helpers/oauth.dart';
import 'package:start_gg_app/screens/followed_events.dart';
import 'package:start_gg_app/screens/registered_events.dart';
import 'package:start_gg_app/screens/find.dart';
import 'package:start_gg_app/screens/onboarding.dart';
import 'package:start_gg_app/widgets/followed_events_fab.dart';
import 'package:start_gg_app/widgets/loading_widget.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Because the entire application relies on oAuth, we check for whether we're loaded here, rather than doing it in each page individually
    final oAuthToken = context.watch<OAuthToken>();
    if (oAuthToken.needToAuthenticate) {
      // Redirect to the onboarding page to prompt the user to login
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // We use SchedulerBinding because we cannot change the page during a build
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
        );
      });
      return const LoadingWidget(reason: "Redirecting to onboarding");
    }
    // The client is null if it hasn't been created yet, but until needToAuthenticate is set, we can't tell if this is due to lack of credentials, or the credentials just aren't loaded yet
    if (oAuthToken.client == null) {
      // Waiting for token to be read, etc
      return const LoadingWidget(reason: "Waiting for credentials");
    }

    Widget page;
    Widget? fab;
    switch (selectedIndex) {
      case 0:
        page = const RegisteredEventsPage();
        break;
      case 1:
        page = const FollowedEventsPage();
        fab = FollowedEventsFAB(context: context);
        break;
      case 2:
        page = Container();
      case 3:
        page = const FindPage();
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
              label: 'Registered',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups),
              label: 'Followed',
            ),
            /* NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ), */
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Find',
            ),
          ],
        ),
        body: SafeArea(child: page),
        floatingActionButton: fab, // May be null
      );
    });
  }
}
