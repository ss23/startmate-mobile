// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/image.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// https://developer.start.gg/reference/game.doc
@freezed
class Game with _$Game {
  const factory Game({
    @JsonKey(fromJson: idFromJson) required String id,
    // Score of entrant 1. For smash, this is equivalent to stocks remaining.
    int? entrant1Score,
    // Score of entrant 2. For smash, this is equivalent to stocks remaining.
    int? entrant2Score,
    @Default([]) List<Image> images,
    int? orderNum,
    // Selections for this game such as character, etc.
    // GameSelection? selections,
    // The stage that this game was played on (if applicable)
    // Stage stage,
    int? state,
    int? winnerId,
  }) = _Game;

  factory Game.fromJson(Map<String, Object?> json) => _$GameFromJson(json);
}
