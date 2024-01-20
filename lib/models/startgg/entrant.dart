// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/event.dart';

part 'entrant.freezed.dart';
part 'entrant.g.dart';

/// https://developer.start.gg/reference/entrant.doc
@freezed
class Entrant with _$Entrant {
  const factory Entrant({
    @JsonKey(fromJson: idFromJson) required String id,
    Event? event,
    // Entrant's seed number in the first phase of the event.
    int? initialSeedNum,
    bool? isDisqualified,
    // The entrant name as it appears in bracket: gamerTag of the participant or team name
    String? name,
    // Paginated sets for this entrant
    // paginatedSets SetConnection
    // List<Participant> participants,
    // List<Seed> seeds,
    int? skill,
    // Standing for this entrant given an event. All entrants queried must be in the same event (for now).
    // Standing standing,
    // List<Stream> streams,
    // Team linked to this entrant, if one exists
    // Team team,
  }) = _Entrant;

  factory Entrant.fromJson(Map<String, Object?> json) => _$EntrantFromJson(json);
}
