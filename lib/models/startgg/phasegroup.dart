// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/phase.dart';
import 'package:startmate/models/startgg/set.dart';

part 'phasegroup.freezed.dart';
part 'phasegroup.g.dart';

/// https://developer.start.gg/reference/phasegroup.doc
@freezed
class PhaseGroup with _$PhaseGroup {
  const factory PhaseGroup({
    @JsonKey(fromJson: idFromJson) required String id,
    // The bracket type of this group's phase.
    // SINGLE_ELIMINATION, DOUBLE_ELIMINATION, ROUND_ROBIN, SWISS, EXHIBITION, CUSTOM_SCHEDULE, MATCHMAKING, ELIMINATION_ROUNDS, RACE, CIRCUIT
    String? bracketType,
    // URL for this phase groups's bracket.
    String? bracketUrl,
    // Unique identifier for this group within the context of its phase
    String? displayIdentifier,
    // For the given phase group, this is the start time of the first round that occurs in the group.
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? firstRoundTime,
    int? numRounds,
    // The phase associated with this phase group
    Phase? phase,
    // The progressions out of this phase group
    // progressionsOut: [Progression]
    // rounds: [Round]
    // JSON
    String? seedMap,
    // Paginated seeds for this phase group
    // seeds(query: SeedPaginationQuery!, eventId: ID): SeedConnection
    // Paginated sets on this phaseGroup
    List<Set>? sets,
    // sets(page: Int, perPage: Int, sortType: SetSortType, filters: SetFilters): SetConnection
    // Paginated list of standings
    // standings(query: StandingGroupStandingPageFilter): StandingConnection
    // Unix time the group is scheduled to start. This info could also be on the wave instead.
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? startAt,
    int? state,
    // JSON
    String? tiebreakOrder,
    // Wave? wave,
  }) = _PhaseGroup;

  const PhaseGroup._();

  factory PhaseGroup.fromJson(Map<String, Object?> json) => _$PhaseGroupFromJson(json);

  String bracketTypeHuman() {
    // TODO: This is untranslated! We should fix this to use the localization system
    final words = bracketType!.split('_').map((word) {
      return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
    });
    return words.join(' ');
  }
}
