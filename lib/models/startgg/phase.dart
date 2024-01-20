// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/event.dart';
import 'package:startmate/models/startgg/phasegroup.dart';

part 'phase.freezed.dart';
part 'phase.g.dart';

/// https://developer.start.gg/reference/phase.doc
@freezed
class Phase with _$Phase {
  const factory Phase({
    @JsonKey(fromJson: idFromJson) required String id,
    // The bracket type of this phase.
    // SINGLE_ELIMINATION, DOUBLE_ELIMINATION, ROUND_ROBIN, SWISS, EXHIBITION, CUSTOM_SCHEDULE, MATCHMAKING, ELIMINATION_ROUNDS, RACE, CIRCUIT
    String? bracketType,
    // The Event that this phase belongs to
    Event? event,
    // Number of phase groups in this phase
    int? groupCount,
    // Is the phase an exhibition or not.
    bool? isExhibition,
    // Name of phase e.g. Round 1 Pools
    String? name,
    // The number of seeds this phase contains.
    int? numSeeds,
    // Phase groups under this phase, paginated
    // phaseGroups(query: PhaseGroupPageQuery): PhaseGroupConnection
    List<PhaseGroup>? phaseGroups,
    // The relative order of this phase within an event
    int? phaseOrder,
    // Paginated seeds for this phase
    // sets(page: Int, perPage: Int, sortType: SetSortType, filters: SetFilters): SetConnection
    // State of the phase
    // CREATED, ACTIVE, COMPLETED, READY, INVALID, CALLED, QUEUED
    String? state,
    // List<Wave> waves,
  }) = _Phase;

  const Phase._();

  factory Phase.fromJson(Map<String, Object?> json) => _$PhaseFromJson(json);

  String bracketTypeHuman() {
    // TODO: This is untranslated! We should fix this to use the localization system
    final words = bracketType!.split('_').map((word) {
      return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
    });
    return words.join(' ');
  }
}
