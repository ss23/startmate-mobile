import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/screens/followed_events.dart';
import 'package:startmate/screens/registered_events.dart';
import 'package:startmate/screens/find.dart';
import 'package:startmate/screens/onboarding.dart';
import 'package:startmate/widgets/followed_events_fab.dart';
import 'package:startmate/widgets/loading_widget.dart';


class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage> {
  final log = Logger('BasePage');
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Because the entire application relies on oAuth, we check for whether we're loaded here, rather than doing it in each page individually
    final oAuthToken = ref.watch(oAuthTokenProvider);
    switch (oAuthToken) {
      case AsyncValue<String>(:final valueOrNull?):
        if (valueOrNull.isEmpty) {
          // In this case, we completed initialization and did not have valid credentials
          SchedulerBinding.instance.addPostFrameCallback((_) {
            // We use SchedulerBinding because we cannot change the page during a build
            log.warning("Redirecting to onboarding");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => OnboardingPage()),
            );
          });
          return const LoadingWidget(reason: "Redirecting to onboarding");
        }
        // This is the case where we were successfully able to obtain the client credentials
        break;
      case AsyncValue(:final error?):
        // There should be no case where we get an error, unless the API is down or similar.
        log.severe(error);
        return const LoadingWidget(reason: "An error occured! Restart the application");
      case _:
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
        page = FindPage();
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
