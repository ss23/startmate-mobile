import 'package:start_gg_app/user.dart';

class FollowedUser {
  // TODO: Decide whether a FollowedUser contains information about the start.gg user, or just references it

  String startggId;
  // TODO: Implement these booleans properly
  //bool followCreatedTournaments;
  //bool followAttendedTournaments;

  User? user;

  FollowedUser(this.startggId);
}