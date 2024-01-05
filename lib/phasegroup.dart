import 'package:startmate/phase.dart';

// https://developer.start.gg/reference/phase.doc
class PhaseGroup {
  PhaseGroup(this.id, this.displayIdentifier);

  int? id;
  int? bracketType; // TODO: https://developer.start.gg/reference/brackettype.doc
  String? bracketUrl;
  String? displayIdentifier;
  DateTime? firstRoundTime;
  int? numRounds;
  Phase? phase;
  String? seedMap;
  DateTime? startAt;
  int? state;
  String? tidebreakOrder;

  /*
  progressionsOut: [Progression]
  rounds: [Round]
  # Paginated seeds for this phase group
  seeds(query: SeedPaginationQuery!, eventId: ID): SeedConnection
  # Paginated sets on this phaseGroup
  sets(page: Int, perPage: Int, sortType: SetSortType, filters: SetFilters): SetConnection
  # Paginated list of standings
  standings(query: StandingGroupStandingPageFilter): StandingConnection
  wave: Wave
  */
}
