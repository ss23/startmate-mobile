import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:startmate/controllers/bracket_event_controller.dart';
import 'package:startmate/models/startgg/event.dart';
import 'package:startmate/models/startgg/tournament.dart';
import 'package:startmate/screens/phasegroup.dart';
import 'package:startmate/widgets/loading_widget.dart';

class BracketPage extends ConsumerWidget {
  BracketPage({required this.event, required this.tournament, super.key});
  final Event event;
  final Tournament tournament;
  final Logger log = Logger('BracketPage');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydratedEvent = ref.watch(fetchBracketEventProvider(eventId: event.id));

    // If only a single Phase for this event exists, we can redirect directly to that phase page
    // This is most useful in the case of a small local, where we save a click by going directly there
    if (hydratedEvent.hasValue && hydratedEvent.value!.phases!.length == 1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PhaseGroupPage(phase: hydratedEvent.value!.phases![0])),
        );
      });
      return LoadingWidget(reason: AppLocalizations.of(context)!.bracketPhaseRedirect);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.name),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchBracketEventProvider(eventId: event.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.bracketBracketLabel),
              const SizedBox(height: 10),
              switch (hydratedEvent) {
                AsyncValue<Event>(:final valueOrNull?) => Expanded(
                    child: ListView.builder(
                      itemCount: valueOrNull.phases!.length,
                      itemBuilder: (BuildContext context, int i) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(valueOrNull.phases![i].name!),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: switch (valueOrNull.phases![i].state!) {
                                    // CREATED, ACTIVE, COMPLETED, READY, INVALID, CALLED, QUEUED
                                    // TODO: Find nice colors for all of these states
                                    'COMPLETED' => Colors.grey,
                                    _ => Colors.blue,
                                  },
                                  borderRadius: const BorderRadius.all(
                                    Radius.elliptical(6, 3),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    valueOrNull.phases![i].state!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${AppLocalizations.of(context)!.bracketEntrantsText(valueOrNull.phases![i].numSeeds!)} · ${AppLocalizations.of(context)!.bracketPoolgroupsText(valueOrNull.phases![i].groupCount!)} · ${valueOrNull.phases![i].bracketTypeHuman()}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PhaseGroupPage(phase: valueOrNull.phases![i])),
                          ),
                        );
                      },
                    ),
                  ),
                AsyncValue(:final error?) => Text(AppLocalizations.of(context)!.genericError(error.toString())),
                _ => const CircularProgressIndicator(),
              },
            ],
          ),
        ),
      ),
    );
  }
}
