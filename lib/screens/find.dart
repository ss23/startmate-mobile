import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/controllers/featured_tournament_controller.dart';
import 'package:startmate/widgets/tournament_widget.dart';

class FindPage extends ConsumerWidget {
  FindPage({super.key});
  final filter = {"upcoming": true};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final featuredTournament = ref.watch(fetchFeaturedTournamentsProvider(filter: filter));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(fetchFeaturedTournamentsProvider(filter: filter));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text('Featured Tournaments', style: theme.textTheme.labelMedium),
          ),
          const SizedBox(height: 10),
          Expanded(
              child: switch (featuredTournament) {
            AsyncData(:final value) => ListView.builder(
                itemCount: value.length,
                itemBuilder: (BuildContext context, int i) {
                  return TournamentWidget(tournament: value[i]);
                }),
            AsyncError() => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No upcoming events found. Register on start.gg and tournaments will show here"),
              ),
            _ => const CircularProgressIndicator(),
          }),
        ],
      ),
    );
  }
}
