import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/helpers/graphql.dart';
import 'package:start_gg_app/helpers/oauth.dart';
import 'package:start_gg_app/models/followed_user.dart';
import 'package:start_gg_app/user.dart';

class FollowedUsersController extends ChangeNotifier {
  List<FollowedUser> _data = [];
  DataState state = DataState.uninitialized;
  final log = Logger('FollowedUsersController');

  FollowedUsersController({ required BuildContext context }) {
    fetch(context);
  }

  List<FollowedUser> data() {
    return _data;
  }

  // TODO: Support paginated results with lazy loading!
  int get length => _data.length;

  FollowedUser operator [](int index) {
    return _data[index];
  }

  void fetch(BuildContext context) async {
    state = DataState.fetching;

    // TODO: Implement database storage of our userIds
    _data = [];

    final userIds = ["1000868","854147"];

    final oauth = Provider.of<OAuthToken>(context, listen: false);
    final accessToken = oauth.client!.credentials.accessToken;

    GraphQLHelper.accessToken = accessToken;
    final client = await GraphQLHelper().client;

    for (var userId in userIds) {
      var query = r'query user($userId: ID!) { user(id: $userId) { id name player { gamerTag } images(type: "profile") { id type url } } }';
      var options = QueryOptions(document: gql(query), variables: {'userId': userId});
      var result = await client.query(options);

      if (result.data == null) {
        if (result.hasException && result.exception!.linkException!.runtimeType == HttpLinkServerException) {
          final exception = result.exception!.linkException! as HttpLinkServerException;
          if (exception.parsedResponse!.response["message"] == "Invalid authentication token") {
            log.warning("Invalid authentication token. Forcing reauthentication");
            oauth.reauthenticate();
            // Clear GraphQL cache too
            client.resetStore(refetchQueries: false);
            return;
          }
        }
        log.warning("Unable to fetch data");
        log.info(result);
        return;
      }

      if (result.data == null || result.data!['user'] == null) {
        log.warning("Unable to fetch user data for ($userId)");
        log.info(result);
        continue;
      }

      var userData = result.data!['user'];

      // TODO: Check if image exists first
      // FIXME: Check if image exists first (e.g. no profile picture)
      var user = User(userData['id'], userData['player']['gamerTag'], userData['images'][0]['url']);
      var followedUser = FollowedUser(userId);
      followedUser.user = user;
      _data.add(followedUser);
    }

    state = DataState.fetched;
    notifyListeners();
  }
}
