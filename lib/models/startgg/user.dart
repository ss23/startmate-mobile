// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/image.dart';
import 'package:startmate/models/startgg/player.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// https://developer.start.gg/reference/user.doc
@freezed
class User with _$User {
  const factory User({
    @JsonKey(fromJson: idFromJson) required String id,
    String? bio,
    String? birthday,

    /// Uniquely identifying token for user. Same as the hashed part of the slug
    String? discriminator,
    String? email,
    String? genderPronoun,
    String? name,
    String? slug,
    // List<ProfileAuthorization> authorizations,
    // List<Event> events,
    @Default([]) List<Image> images,
    // List<League> leagues,
    // Address address,
    Player? player,
    // List<Tournaments> tournaments,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

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
