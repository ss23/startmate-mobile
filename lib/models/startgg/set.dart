// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/event.dart';
import 'package:startmate/models/startgg/image.dart';
import 'package:startmate/models/startgg/phasegroup.dart';
import 'package:startmate/models/startgg/setslot.dart';

part 'set.freezed.dart';
part 'set.g.dart';

/// https://developer.start.gg/reference/set.doc
@freezed
class Set with _$Set {
  const factory Set({
    @JsonKey(fromJson: idFromJson) required String id,
    // The time this set was marked as completed
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? completedAt,
    // The time this set was created
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? createdAt,
    // displayScore(mainEntrantId: ID): String
    // Event that this set belongs to.
    Event? event,
    // Full round text of this set.
    String? fullRoundText,
    // game(orderNum: Int!): Game
    // List<Game> games,
    // Whether this set contains a placeholder entrant
    bool? hasPlaceholder,
    // The letters that describe a unique identifier within the pool. Eg. F, AT
    String? identifier,
    List<Image>? images,
    int? lPlacement,
    // Phase group that this Set belongs to.
    PhaseGroup? phaseGroup,
    // The sets that are affected from resetting this set
    // ResetAffectedData resetAffectedData,
    // The round number of the set. Negative numbers are losers bracket
    int? round,
    // Indicates whether the set is in best of or total games mode. This instructs
    // which field is used to figure out how many games are in this set.
    int? setGamesType,
    // A possible spot in a set. Use this to get all entrants in a set. Use this for
    // all bracket types (FFA, elimination, etc)
    List<SetSlot>? slots,
    // The start time of the Set. If there is no startAt time on the Set, will pull it
    // from phaseGroup rounds configuration.
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? startAt,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? startedAt,
    int? state,
    // Tournament event station for a set
    // Stations station,
    // Tournament event stream for a set
    // Streams stream,
    // If setGamesType is in total games mode, this defined the number of games in the
    // set.
    int? totalGames,
    // Url of a VOD for this set
    String? vodUrl,
    int? wPlacement,
    int? winnerId,
  }) = _Set;

  factory Set.fromJson(Map<String, Object?> json) => _$SetFromJson(json);
}
