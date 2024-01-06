// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:startmate/helpers/startgg_parsing_helpers.dart';
import 'package:startmate/models/startgg/image.dart';
import 'package:startmate/models/startgg/tournament.dart';
import 'package:startmate/models/startgg/videogame.dart';

part 'event.freezed.dart';
part 'event.g.dart';

/// https://developer.start.gg/reference/event.doc
@freezed
class Event with _$Event {
  const factory Event({
    @JsonKey(fromJson: idFromJson) required String id,
    // Title of event set by organizer
    required String name,
    // How long before the event start will the check-in end (in seconds)
    int? checkInBuffer,
    // How long the event check-in will last (in seconds)
    int? checkInDuration,
    // Whether check-in is enabled for this event
    bool? checkInEnabled,
    // Rough categorization of event tier, denoting relative importance in the competitive scene
    int? competitionTier,
    // When the event was created
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull)
    DateTime? createdAt,
    // Last date attendees are able to create teams for team events
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull)
    DateTime? deckSubmissionDeadline,
    // The entrants that belong to an event, paginated by filter criteria
    // List<Entrant> entrants,
    // Whether the event has decks
    bool? hasDecks,
    // Are player tasks enabled for this event
    bool? hasTasks,
    List<Image>? images,
    // Whether the event is an online event or not
    bool? isOnline,
    // List<League>? league,
    // Markdown field for match rules/instructions
    String? matchRulesMarkdown,
    // Gets the number of entrants in this event
    int? numEntrants,
    // The phase groups that belong to an event.
    // PhaseGroup phaseGroups,
    // The phases that belong to an event.
    // List<Phase> phases,
    // TO settings for prizing
    // prizingInfo: JSON
    // publishing: JSON
    // Markdown field for event rules/instructions
    String? rulesMarkdown,
    // Id of the event ruleset
    int? rulesetId,
    // Sets for this Event
    // List<Set> sets
    String? slug,
    // List<Standing> standings
    // When does this event start?
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull)
    DateTime? startAt,
    // The state of the Event.
    // ActivityState::CREATED, ActivityState::ACTIVE, ActivityState::COMPLETED
    String? state,
    // Stations on this event
    // List<Station> stations
    // Last date attendees are able to create teams for team events
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull)
    DateTime? teamManagementDeadline,
    // If this is a teams event, returns whether or not teams can set custom names
    bool? teamNameAllowed,
    // Team roster size requirements
    // TeamRosterSize teamRosterSize,
    Tournament? tournament,
    // The type of the event, whether an entrant will have one participant or multiple
    int? type,
    // When the event was last modified (unix timestamp)
    @JsonKey(fromJson: datetimeFromTimestamp, defaultValue: datetimeNull)
    DateTime? updatedAt,
    // Whether the event uses the new EventSeeds for seeding
    bool? useEventSeeds,
    Videogame? videogame,
    // The waves being used by the event
    // Wave wave,
  }) = _Event;

  const Event._();

  factory Event.fromJson(Map<String, Object?> json) => _$EventFromJson(json);

  Image? image(String type) {
    if (images == null || images!.isEmpty) {
      return null;
    }
    for (final im in images!) {
      if (im.type == type) return im;
    }
    return null;
  }
}
