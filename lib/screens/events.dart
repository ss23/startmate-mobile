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
      create: (context) => TournamentController(context: context, filter: {"upcoming": true}),
      child: Consumer<TournamentController>(
        builder: (BuildContext context, TournamentController controller, Widget? _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text('Tournaments', style: theme.textTheme.labelMedium),
              ),
              const SizedBox(height: 10),
              RefreshIndicator(
                  onRefresh: () async {
                    controller.fetch(context);
                  },
                  child: Column(
                    children: [
                      if (controller.state == DataState.fetching || controller.state == DataState.uninitialized) const Center(child: CircularProgressIndicator()),
                      if ((controller.state == DataState.fetched || controller.state == DataState.endOfData) && controller.length == 0)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No upcoming events found. Register on start.gg and tournaments will show here"),
                        ),
                    ],
                  )),
              // TODO: There is a bug that prevents us putting all of this content inside a single RefreshIndicator. Investigate and fix.
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    controller.fetch(context);
                  },
                  child: ListView.builder(
                      itemCount: controller.length,
                      itemBuilder: (BuildContext context, int i) {
                        return TournamentWidget(tournament: controller[i]);
                      }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
