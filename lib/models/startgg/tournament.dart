// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/event.dart';
import 'package:startmate/models/startgg/image.dart';
import 'package:startmate/models/startgg/user.dart';

part 'tournament.freezed.dart';
part 'tournament.g.dart';

/// https://developer.start.gg/reference/tournament.doc
@freezed
class Tournament with _$Tournament {
  const factory Tournament({
    @JsonKey(fromJson: idFromJson) required String id,
    required String name,
    String? addrState,
    // Only tournament administrators can view the other admins
    // List<user> admins,
    String? city,
    String? countryCode,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? createdAt,
    String? currency,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? endAt,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? eventRegistrationClosesAt,
    List<Event>? events,
    bool? hasOfflineEvents,
    bool? hasOnlineEvents,
    String? hashtag,
    @Default([]) List<Image> images,
    bool? isOnline,
    bool? isRegistrationOpen,
    double? lat,
    double? lng,
    String? mapsPlaceId,
    int? numAttendees,
    User? owner,
    // List<Participant> participants,
    String? postalCode,
    String? primaryContact,
    String? primaryContactType,
    // JSON? publishing,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? registrationClosesAt,
    String? rules,
    String? shortSlug,
    String? slug,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? startAt,
    // ActivityState::CREATED, ActivityState::ACTIVE, ActivityState::COMPLETED
    int? state,
    // List<Station> stations,
    // StreamQueue streamQueue,
    /// The documentation calls this "streams", rather than "List<Stream>"
    // Streams streams,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? teamCreationClosesAt,
    // List<Team> teams,
    String? timezone,
    int? tournamentType,
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull) DateTime? updatedAt,
    String? url,
    String? venueAddress,
    String? venueName,
    // List<Wave> waves,
    // This field comes from the Featured Tournaments query, not the official documentation
    String? locationDisplayName,
  }) = _Tournament;

  const Tournament._();

  factory Tournament.fromJson(Map<String, Object?> json) => _$TournamentFromJson(json);

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
