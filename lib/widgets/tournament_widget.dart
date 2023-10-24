import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/bracket.dart';
import 'package:start_gg_app/helpers/url.dart';
import 'package:start_gg_app/controllers/appstate_controller.dart';
import 'package:start_gg_app/tournament.dart';
import 'package:transparent_image/transparent_image.dart';

class TournamentWidget extends StatelessWidget {
  final Tournament tournament;
  final Logger log = Logger("TournamentWidget");

  TournamentWidget({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppStateController>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          log.finer("Clicked tournament");
          urlLaunch(Uri.parse('https://www.start.gg/${tournament.slug}'));
        },
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: SizedBox(
                  height: 60,
                  child: FittedBox(
                    //alignment: Alignment.topCenter,
                    fit: BoxFit.fitWidth,
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      // TODO: Replace this with a real placeholder image (or plain color or something, who knows)
                      image: tournament.imageURL ?? 'https://images.start.gg/images/tournament/599117/image-a8543c0cc170271d6caf8df258650fec-optimized.png',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tournament.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const Icon(Icons.more_vert)
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month),
                      Text(DateFormat('yyyy-MM-dd – kk:mm').format(tournament.startAt)),
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      Text(tournament.city),
                    ],
                  )),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Column(children: [
                  for (int j = 0; j < tournament.events.length; j++)
                    Column(
                        children: [
                          GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        log.finer("Clicked event");
                        urlLaunch(Uri.parse('https://www.start.gg/${tournament.events[j].slug}'));
                      },
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(
                              height: 120,
                              child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: tournament.events[j].videogame.imageURL ?? 'https://images.start.gg/images/videogame/9352/image-652433aa40f80e55d076647313d6bb14-optimized.jpg',
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          tournament.events[j].name,
                                          style: theme.textTheme.headlineSmall,
                                        ),
                                        // TODO: Use a different icon/interaction if we haven't registered for this event
                                        // tODO: Fix this so we can show an icon for if we're registered!
                                        //if (appState.currentUser!.upcomingEvents.contains(tournament.events[j].id)) const Icon(Icons.check_circle_outline, color: Colors.green)
                                      ],
                                    ),
                                    Text(tournament.events[j].videogame.name),
                                    Text('${tournament.events[j].numEntrants} entrants'),
                                    FilledButton(
                                      // TODO: Take us to the bracket view page
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => EventBracketPage(event: tournament.events[j], appState: appState)),
                                        );
                                      },
                                      child: const Text("Bracket"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                          ),
                          if (j != (tournament.events.length - 1)) const Divider()
                        ],
                      ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
