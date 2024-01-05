import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/controllers/followed_tournament_controller.dart';
import 'package:startmate/controllers/followed_users_controller.dart';
import 'package:startmate/widgets/tournament_widget.dart';
import 'package:startmate/widgets/user_badge_widget.dart';

class FollowedEventsPage extends ConsumerWidget {
  const FollowedEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final followedUsersController = ref.watch(followedUsersProvider);
    final followedTournamentController = ref.watch(FetchFollowedTournamentsProvider(const {'upcoming': true}));

    // TODO: Replace this with an inline version instead of pulling it out here (had syntax errors when I tried)
    Widget followedUsersWidget;
    switch (followedUsersController) {
      case AsyncData(:final value):
        if (value.isEmpty) {
          followedUsersWidget = const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Follow a user to see their events!'),
          );
        } else {
          followedUsersWidget = ListView.builder(
            itemCount: value.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int i) {
              return UserBadgeWidget(
                value[i].user,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(followedUsersProvider.notifier).unfollowUser(id: value[i].user.id!);
                    },
                    child: const Text('Unfollow'),
                  ),
                ],
              );
            },
          );
        }
      case AsyncError(:final error):
        followedUsersWidget = Padding(
          padding: const EdgeInsets.all(16),
          child: Text('An error occured. Try again later, or submit a bug! $error'),
        );
      case _:
        followedUsersWidget = const Center(child: CircularProgressIndicator());
    }

    Widget followedTournaments;
    switch (followedTournamentController) {
      case AsyncData(:final value):
        if (value.isEmpty) {
          followedTournaments = const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No upcoming tournaments found. Follow more people to see their tournaments!'),
          );
        } else {
          followedTournaments = ListView.builder(
            itemCount: value.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
            itemBuilder: (BuildContext context, int i) {
              return TournamentWidget(tournament: value[i]);
            },
          );
        }
      case AsyncError(:final error):
        followedTournaments = Padding(
          padding: const EdgeInsets.all(16),
          child: Text('An error occured. Try again later, or submit a bug! $error'),
        );
      case _:
        followedTournaments = const Center(child: CircularProgressIndicator());
    }

    // TODO: Wrap this in a refreshindicator?
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text('Followed Users', style: theme.textTheme.labelMedium),
          ),
          SizedBox(
            height: 100,
            child: followedUsersWidget,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text('Tournaments', style: theme.textTheme.labelMedium),
          ),
          const SizedBox(height: 10),
          followedTournaments,
        ],
      ),
    );
  }
}
