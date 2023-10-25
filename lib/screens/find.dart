import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/controllers/featured_tournament_controller.dart';
import 'package:start_gg_app/widgets/tournament_widget.dart';

class FindPage extends StatelessWidget {
  const FindPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
            create: (context) => FeaturedTournamentController(context: context, filter: {"upcoming": true}),
            child: Consumer<FeaturedTournamentController>(
              builder: (BuildContext context, FeaturedTournamentController controller, Widget? _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Text('Featured Tournaments', style: theme.textTheme.labelMedium),
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
                                  child: Text("No upcoming events found. Register on start.gg and tournaments will show here"),
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
