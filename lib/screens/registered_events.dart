import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/controllers/tournament_controller.dart';
import 'package:startmate/widgets/tournament_widget.dart';

class RegisteredEventsPage extends ConsumerWidget {
  const RegisteredEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    const filter = {'upcoming': true};

    final tournamentController = ref.watch(FetchTournamentsProvider(filter: filter));

    // TODO: There is image pop-in even with the transparent image used here. Fix this.
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(FetchTournamentsProvider(filter: filter));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text('Registered Tournaments', style: theme.textTheme.labelMedium),
          ),
          const SizedBox(height: 10),
          switch (tournamentController) {
            AsyncData(:final value) => Expanded(
                child: ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (BuildContext context, int i) {
                    return TournamentWidget(tournament: value[i]);
                  },
                ),
              ),
            AsyncError() => const Padding(
                padding: EdgeInsets.all(16),
                child: Text("You aren't registered for any upcoming tournaments. As registration is not currently supported in this application, register on start.gg and come back here."),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ],
      ),
    );
  }
}
