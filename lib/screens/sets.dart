import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:startmate/controllers/bracket_set_controller.dart';
import 'package:startmate/models/startgg/phasegroup.dart';
import 'package:startmate/models/startgg/set.dart';
import 'package:startmate/widgets/bracket_widget.dart';

class SetsPage extends ConsumerWidget {
  SetsPage({required this.phaseGroup, super.key});
  final PhaseGroup phaseGroup;
  final Logger log = Logger('SetsPage');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(fetchBracketSetProvider(phaseGroupId: phaseGroup.id));

    // We want to visually distinguish between losers and winners sets, so we sort them into buckets here
    // We use SplayTreeMap because we need these rounds to be sorted, rather than in API order
    final winnersSetsByRound = SplayTreeMap<int, List<Set>>.from({});
    final losersSetsByRound = SplayTreeMap<int, List<Set>>.from({});
    if (sets.hasValue) {
      for (final set in sets.requireValue) {
        if (set.round! > 0) {
          if (winnersSetsByRound[set.round] == null) {
            winnersSetsByRound[set.round!] = [];
          }
          winnersSetsByRound[set.round]!.add(set);
        } else {
          if (losersSetsByRound[set.round] == null) {
            losersSetsByRound[set.round!] = [];
          }
          losersSetsByRound[set.round]!.add(set);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchBracketSetProvider(phaseGroupId: phaseGroup.id));
        },
        child: switch (sets) {
          // ignore: unused_local_variable
          AsyncValue<List<Set>>(:final valueOrNull?) => SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Winners sets
                    Row(
                      children: [
                        for (final roundSets in winnersSetsByRound.values) BracketWidget(sets: roundSets),
                      ],
                    ),
                    // Losers sets
                    Row(
                      children: [
                        // Because we need this in reversed order, we convert to a list here
                        // TODO: Reverse the order of the splayed map instead of extra work here
                        for (final roundSets in losersSetsByRound.values.toList().reversed) BracketWidget(sets: roundSets),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          AsyncValue(:final error?) => Text(AppLocalizations.of(context)!.genericError(error.toString())),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }
}
