import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/tournament_controller.dart';
import 'package:start_gg_app/widgets/tournament_widget.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: There is image popin even with the transparent image used here. Fix this.

    return ChangeNotifierProvider(
      create: (context) => TournamentController(filter: {"upcoming": true}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text('Tournaments', style: theme.textTheme.labelMedium),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Consumer<TournamentController>(
              builder: (BuildContext context, TournamentController controller, Widget? _) {
                return RefreshIndicator(
                  onRefresh: () async {
                    controller.fetch(context);
                  },
                  child: ListView.builder(
                      itemCount: controller.length,
                      itemBuilder: (BuildContext context, int i) {
                        return TournamentWidget(tournament: controller[i]);
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}