// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/entrant.dart';

part 'setslot.freezed.dart';
part 'setslot.g.dart';

/// https://developer.start.gg/reference/setslot.doc
@freezed
class SetSlot with _$SetSlot {
  const factory SetSlot({
    @JsonKey(fromJson: idFromJson) required String id,
    Entrant? entrant,
    // Pairs with prereqType, is the ID of the prereq.
    String? prereqId,
    // Given a set prereq type, defines the placement required in the origin set to end
    // up in this slot.
    int? prereqPlacement,
    // Describes where the entity in this slot comes from.
    String? prereqType,
    // Seed seed,
    // The index of the slot. Unique per set.
    int? slotIndex,
    // The standing within this set for the seed currently assigned to this slot.
    // Standing standing,
  }) = _SetSlot;

  factory SetSlot.fromJson(Map<String, Object?> json) => _$SetSlotFromJson(json);
}
