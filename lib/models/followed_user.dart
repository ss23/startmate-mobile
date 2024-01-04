import 'package:startmate/user.dart';

class FollowedUser {
  // TODO: Decide whether a FollowedUser contains information about the start.gg user, or just references it

  // TODO: Implement these booleans properly
  //bool followCreatedTournaments;
  //bool followAttendedTournaments;

  User user;

  // These keys correspond to those in the database
  Map<String, dynamic> toMap() {
    return {
      'id': user.id!,
    };
  }

  FollowedUser(this.user);
}