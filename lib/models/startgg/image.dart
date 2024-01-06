// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';

part 'image.freezed.dart';
part 'image.g.dart';

/// https://developer.start.gg/reference/image.doc
@freezed
class Image with _$Image {
  const factory Image({
    @JsonKey(fromJson: idFromJson) required String id,
    required String type,
    required String url,
    // Float? height,
    // Float? width,
    // Float? ratio,
  }) = _Image;

  factory Image.fromJson(Map<String, Object?> json) => _$ImageFromJson(json);
}
