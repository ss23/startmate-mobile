import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:startmate/models/startgg/set.dart';

class BracketWidget extends StatelessWidget {
  const BracketWidget({required this.sets, super.key});

  final List<Set> sets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (final set in sets)
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                      ),
                      padding: const EdgeInsets.only(left: 14, right: 8, top: 1, bottom: 1),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              (set.slots![0].entrant != null) ? set.slots![0].entrant!.name! : '',
                              overflow: TextOverflow.ellipsis,
                              style: (set.slots![0].entrant != null && set.slots![0].entrant!.id == set.winnerId.toString()) ? const TextStyle(fontWeight: FontWeight.bold) : null,
                            ),
                          ),
                          if (set.slots![0].entrant != null && set.slots![0].entrant!.isDisqualified != null && set.slots![0].entrant!.isDisqualified!) Text(AppLocalizations.of(context)!.bracketDisqualified) else Container(),
                        ],
                      ),
                    ),
                    Container(
                      width: 200,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(color: Color(0xFFDDDDDD)),
                          right: BorderSide(color: Color(0xFFDDDDDD)),
                          bottom: BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 14, right: 8, top: 1, bottom: 1),
                      child: Text(
                        (set.slots![1].entrant != null) ? set.slots![1].entrant!.name! : '',
                        overflow: TextOverflow.ellipsis,
                        style: (set.slots![1].entrant != null && set.slots![1].entrant!.id == set.winnerId.toString()) ? const TextStyle(fontWeight: FontWeight.bold) : null,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 18),
                  decoration: const BoxDecoration(
                    // TODO: This Border Radius looks silly, make it nicer (hard edges probably, more like an arrow)
                    borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                    color: Colors.blue,
                  ),
                  child: Text(set.identifier!, style: theme.textTheme.labelLarge!.merge(const TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
