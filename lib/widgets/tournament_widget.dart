import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:startmate/controllers/current_user_controller.dart';
import 'package:startmate/controllers/followed_users_controller.dart';
import 'package:startmate/controllers/user_registered_controller.dart';
import 'package:startmate/helpers/url.dart';
import 'package:startmate/models/startgg/tournament.dart';
import 'package:startmate/screens/bracket.dart';
import 'package:transparent_image/transparent_image.dart';

class TournamentWidget extends ConsumerWidget {
  TournamentWidget({required this.tournament, super.key});
  final Tournament tournament;
  final Logger log = Logger('TournamentWidget');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final registeredUsers = ref.watch(fetchRegisteredUsersProvider(id: tournament.id));
    final currentUser = ref.watch(fetchCurrentUserProvider);
    final followedUsers = ref.watch(followedUsersProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: GestureDetector(
        onTap: () {
          log.finer('Clicked tournament');
          urlLaunch(Uri.parse('https://www.start.gg/${tournament.slug}'));
        },
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tournament.image('profile') != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: SizedBox(
                    height: 60,
                    child: FittedBox(
                      //alignment: Alignment.topCenter,
                      fit: BoxFit.fitWidth,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Image.memory(kTransparentImage),
                        imageUrl: tournament.image('profile')!.url,
                      ),
                    ),
                  ),
                ),
              switch (registeredUsers) {
                AsyncData(:final value) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (value.where((item) => item.id == currentUser.requireValue.id).isEmpty)
                          FilledButton.icon(
                            icon: const Icon(Icons.login),
                            onPressed: () {
                              urlLaunch(Uri.parse('https://www.start.gg/${tournament.slug}/register'));
                            },
                            label: Text(AppLocalizations.of(context)!.tournamentRegisterLabel),
                          )
                        else
                          const Icon(Icons.check_circle_outline, color: Colors.green),
                        Expanded(
                          child: Row(
                            children: [
                              // Show only avatars of your followed users
                              if (followedUsers is AsyncError || followedUsers is AsyncLoading)
                                Container()
                              else
                                for (final user in value.where((u) => followedUsers.requireValue.map((e) => e.user.id).contains(u.id)))
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 4),
                                    child: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: (user.image('profile') != null)
                                          ? CachedNetworkImage(
                                              imageUrl: user.image('profile')!.url,
                                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                                radius: 50,
                                                backgroundImage: imageProvider,
                                              ),
                                              placeholder: (context, url) => const CircularProgressIndicator(),
                                            )
                                          : Container(),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert),
                      ],
                    ),
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(AppLocalizations.of(context)!.genericError(error.toString())),
                  ),
                _ => const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              },
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tournament.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    // TODO: i18n for this date
                    Text(DateFormat('yyyy-MM-dd - kk:mm').format(tournament.startAt!)),
                  ],
                ),
              ),
              if (tournament.city != null || tournament.locationDisplayName != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      Text(tournament.locationDisplayName ?? tournament.city!),
                    ],
                  ),
                ),
              if (tournament.events != null && tournament.events!.isNotEmpty) const Divider(),
              if (tournament.events != null && tournament.events!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Column(
                    children: [
                      for (int j = 0; j < tournament.events!.length; j++)
                        Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                log.finer('Clicked event');
                                urlLaunch(Uri.parse('https://www.start.gg/${tournament.events![j].slug}'));
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 120,
                                    width: 90, // This width is based on the aspect ratio of the videogame images
                                    child: CachedNetworkImage(
                                      imageUrl: tournament.events![j].videogame!.image('primary')!.url, // Every videogame should have primary image
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tournament.events![j].name,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.headlineSmall,
                                                ),
                                              ),
                                              // TODO: Use a different icon/interaction if we haven't registered for this event
                                              // TODO: Fix this so we can show an icon for if we're registered!
                                              //if (appState.currentUser!.upcomingEvents.contains(tournament.events[j].id)) const Icon(Icons.check_circle_outline, color: Colors.green)
                                            ],
                                          ),
                                          Text(tournament.events![j].videogame!.displayName),
                                          Text(AppLocalizations.of(context)!.tournamentEventEntrantsText(tournament.events![j].numEntrants!)),
                                          FilledButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => BracketPage(event: tournament.events![j], tournament: tournament)),
                                              );
                                            },
                                            child: Text(AppLocalizations.of(context)!.tournamentBracketButton),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (j != (tournament.events!.length - 1)) const Divider(),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
