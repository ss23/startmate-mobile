// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/image.dart';

part 'videogame.freezed.dart';
part 'videogame.g.dart';

/// https://developer.start.gg/reference/videogame.doc
@freezed
class Videogame with _$Videogame {
  const factory Videogame({
    @JsonKey(fromJson: idFromJson) required String id,
    required String displayName,
    // All characters for this videogame
    // List<Character> characters,
    @Default([]) List<Image> images,
    String? name,
    String? slug,
    // List<Stage> stages,
  }) = _Videogame;

  const Videogame._();

  factory Videogame.fromJson(Map<String, Object?> json) => _$VideogameFromJson(json);

  Image? image(String type) {
    if (images.isEmpty) {
      return null;
    }
    for (final im in images) {
      if (im.type == type) return im;
    }
    return null;
  }
}
