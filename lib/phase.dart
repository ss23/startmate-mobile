import 'package:start_gg_app/event.dart';
import 'package:start_gg_app/phasegroup.dart';

// https://developer.start.gg/reference/phase.doc
class Phase {
  int? id;
  int? bracketType; // TODO: https://developer.start.gg/reference/brackettype.doc
  Event? event;
  int? groupCount;
  bool? isExhibition;
  String? name;
  int? numSeeds;
  int? phaseOrder;
  int? activityState; // ActivityState::CREATED, ActivityState::ACTIVE, ActivityState::COMPLETED
  List<PhaseGroup> phaseGroups = [];

  Phase(this.id, this.name);

  /*
  # Phase groups under this phase, paginated
  phaseGroups(query: PhaseGroupPageQuery): PhaseGroupConnection
  # Paginated seeds for this phase
  seeds(query: SeedPaginationQuery!, eventId: ID): SeedConnection
  # Paginated sets for this Phase
  sets(page: Int, perPage: Int, sortType: SetSortType, filters: SetFilters): SetConnection
  waves: [Wave]
  */
}