import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/controllers/tournament_controller.dart';
import 'package:start_gg_app/widgets/tournament_widget.dart';

class RegisteredEventsPage extends StatelessWidget {
  const RegisteredEventsPage({super.key});

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
                child: Text('Registered Tournaments', style: theme.textTheme.labelMedium),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    controller.fetch(context);
                  },
                  child: ListView.builder(
                    itemCount: controller.length + 1,
                    itemBuilder: (BuildContext context, int i) {
                      if (i == 0) {
                        if (controller.state == DataState.fetching || controller.state == DataState.uninitialized) {
                          return const Center(child: CircularProgressIndicator());
                        } else if ((controller.state == DataState.fetched || controller.state == DataState.endOfData) && controller.length == 0) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text("You aren't registered for any upcoming tournaments. As registration is not currently supported in this application, register on start.gg and come back here."),
                          );
                        } else {
                          return Container(); // Empty placeholder for refreshing indicator.
                        }
                      }
                      return TournamentWidget(tournament: controller[i - 1]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
