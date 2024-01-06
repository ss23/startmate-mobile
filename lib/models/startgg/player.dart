// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/user.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// https://developer.start.gg/reference/player.doc
@freezed
class Player with _$Player {
  const factory Player({
    @JsonKey(fromJson: idFromJson) required String id,
    String? gamerTag,
    String? prefix,
    User? user,
    // List<PlayerRank> rankings
    // List<Standing> recentStandings
    // List<Set> sets
  }) = _Player;

  factory Player.fromJson(Map<String, Object?> json) => _$PlayerFromJson(json);
}
