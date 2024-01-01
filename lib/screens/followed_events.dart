import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/controllers/followed_tournament_controller.dart';
import 'package:start_gg_app/controllers/followed_users_controller.dart';
import 'package:start_gg_app/widgets/tournament_widget.dart';
import 'package:start_gg_app/widgets/user_badge_widget.dart';

class FollowedEventsPage extends StatelessWidget {
  const FollowedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => FollowedUsersController(context: context)),
          ChangeNotifierProxyProvider<FollowedUsersController, FollowedTournamentController>(
            create: (context) => FollowedTournamentController(context: context, filter: {"upcoming": true}),
            update: (context, followedUsersController, followedTournamentController) {
              followedTournamentController?.update(context, followedUsersController);
              return followedTournamentController!;
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text('Followed Users', style: theme.textTheme.labelMedium),
              ),
              Consumer<FollowedUsersController>(
                builder: (BuildContext context, FollowedUsersController usersController, Widget? _) {
                  return SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: usersController.length + 1,
                      itemBuilder: (BuildContext context, int i) {
                        if (i == 0) {
                          if (usersController.state == DataState.fetching || usersController.state == DataState.uninitialized) {
                            return const Center(child: CircularProgressIndicator());
                          } else if ((usersController.state == DataState.fetched || usersController.state == DataState.endOfData) && usersController.length == 0) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("Follow a user to see their events!"),
                            );
                          } else {
                            return Container(); // Empty placeholder for refreshing indicator.
                          }
                        }
                        return UserBadgeWidget(usersController[i - 1].user!);
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text('Tournaments', style: theme.textTheme.labelMedium),
              ),
              const SizedBox(height: 10),
              Consumer<FollowedTournamentController>(builder: (BuildContext context, FollowedTournamentController controller, Widget? _) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
                  itemCount: controller.length + 1,
                  itemBuilder: (BuildContext context, int i) {
                    if (i == 0) {
                      if (controller.state == DataState.fetching || controller.state == DataState.uninitialized) {
                        return const Center(child: CircularProgressIndicator());
                      } else if ((controller.state == DataState.fetched || controller.state == DataState.endOfData) && controller.length == 0) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No upcoming tournaments found. Follow more people to see their tournaments!"),
                        );
                      } else {
                        return Container(); // Empty placeholder for refreshing indicator.
                      }
                    }
                    return TournamentWidget(tournament: controller[i - 1]);
                  },
                );
              }),
            ],
          ),
        ));
  }
}
