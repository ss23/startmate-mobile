import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:startmate/controllers/bracket_phase_controller.dart';
import 'package:startmate/l10n/app_localizations.dart';
import 'package:startmate/models/startgg/phase.dart';
import 'package:startmate/models/startgg/phasegroup.dart';
import 'package:startmate/screens/sets.dart';
import 'package:startmate/widgets/loading_widget.dart';

class PhaseGroupPage extends ConsumerWidget {
  PhaseGroupPage({required this.phase, super.key});
  final Phase phase;
  final Logger log = Logger('PhaseGroupPage');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydratedPhaseGroups = ref.watch(fetchBracketPhaseProvider(phaseId: phase.id));

    // If only a single PhaseGroup for this Phase exists, we can redirect directly to that Set page
    // This is most useful in the case of a small local, where we save a click by going directly there
    if (hydratedPhaseGroups.hasValue && hydratedPhaseGroups.value!.length == 1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SetsPage(phaseGroup: hydratedPhaseGroups.value![0])),
        );
      });
      return LoadingWidget(reason: AppLocalizations.of(context)!.bracketPhaseGroupRedirect);
    }

    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchBracketPhaseProvider(phaseId: phase.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              switch (hydratedPhaseGroups) {
                AsyncValue<List<PhaseGroup>>(:final valueOrNull?) => Expanded(
                    child: ListView.builder(
                      itemCount: valueOrNull.length,
                      itemBuilder: (BuildContext context, int i) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.bracketPhaseGroupLabel(valueOrNull[i].displayIdentifier!)),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: switch (valueOrNull[i].state!) {
                                    // CREATED, ACTIVE, COMPLETED, READY, INVALID, CALLED, QUEUED
                                    // TODO: Find nice colors for all of these states
                                    // TODO: Which number refers to which state?
                                    3 => Colors.grey,
                                    _ => Colors.blue,
                                  },
                                  borderRadius: const BorderRadius.all(
                                    Radius.elliptical(6, 3),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    switch (valueOrNull[i].state!) {
                                      // TODO: Implement all states
                                      3 => 'COMPLETED',
                                      _ => 'UNKNOWN',
                                    },
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SetsPage(phaseGroup: valueOrNull[i])),
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
