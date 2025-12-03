import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/controllers/followed_tournament_controller.dart';
import 'package:startmate/controllers/followed_users_controller.dart';
import 'package:startmate/l10n/app_localizations.dart';
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
          followedUsersWidget = Padding(
            padding: const EdgeInsets.all(16),
            child: Text(AppLocalizations.of(context)!.followUserEmpty),
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
                      ref.read(followedUsersProvider.notifier).unfollowUser(id: value[i].user.id);
                    },
                    child: Text(AppLocalizations.of(context)!.followUserUnfollowLabel),
                  ),
                ],
              );
            },
          );
        }
      case AsyncError(:final error):
        followedUsersWidget = Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.genericError(error.toString())),
        );
      case _:
        followedUsersWidget = const Center(child: CircularProgressIndicator());
    }

    Widget followedTournaments;
    switch (followedTournamentController) {
      case AsyncData(:final value):
        if (value.isEmpty) {
          followedTournaments = Padding(
            padding: const EdgeInsets.all(16),
            child: Text(AppLocalizations.of(context)!.followUserTournamentsEmpty),
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
          child: Text(AppLocalizations.of(context)!.genericError(error.toString())),
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
            child: Text(AppLocalizations.of(context)!.followUserUsersLabel, style: theme.textTheme.labelMedium),
          ),
          SizedBox(
            height: 100,
            child: followedUsersWidget,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(AppLocalizations.of(context)!.followUserTournamentsLabel, style: theme.textTheme.labelMedium),
          ),
          const SizedBox(height: 10),
          followedTournaments,
        ],
      ),
    );
  }
}
