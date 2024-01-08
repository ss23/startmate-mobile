import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:startmate/helpers/database.dart';
import 'package:startmate/helpers/graphql.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/models/followed_user.dart';
import 'package:startmate/models/startgg/user.dart';

part 'followed_users_controller.g.dart';

@riverpod
class FollowedUsers extends _$FollowedUsers {
  final _log = Logger('FollowedUsers');

  Future<List<FollowedUser>> _fetch() async {
    final db = await DatabaseHelper().database;
    final users = await db.query('followed_users');
    final followedUsers = users.map((u) => u['id']).toList().cast<String>();

    final accessToken = ref.watch(oAuthTokenProvider).requireValue;

    GraphQLHelper.accessToken = accessToken;
    final client = await GraphQLHelper().client;

    final data = <FollowedUser>[];

    for (final userId in followedUsers) {
      const query = r'query user($userId: ID!) { user(id: $userId) { id name player { id gamerTag prefix } images { id type url } } }';
      final options = QueryOptions(document: gql(query), variables: {'userId': userId});
      final result = await client.query(options);

      if (result.data == null) {
        if (result.hasException) {
          if (result.exception!.linkException!.runtimeType == HttpLinkServerException) {
            final exception = result.exception!.linkException! as HttpLinkServerException;
            if (exception.parsedResponse!.response['message'] == 'Invalid authentication token') {
              _log.warning('Invalid authentication token. Forcing reauthentication');
              await ref.read(oAuthTokenProvider.notifier).forceReset();
              ref.invalidate(oAuthTokenProvider);
              // Clear GraphQL cache too
              await client.resetStore(refetchQueries: false);
            }
          }
          _log.warning('Unable to fetch data due to exception');
          throw result.exception!;
        }
        _log.warning('Unable to fetch data but no exception triggered');
        _log.info(result);
        throw Exception('Unable to fetch followed user data');
      }

      if (result.data == null || result.data!['user'] == null) {
        _log.warning('Unable to fetch user data for ($userId)');
        _log.info(result);

        // We still want to give users a way of clearing/removing this broken user, since it could be persistent and slow down servers, etc etc
        // TODO: Decide whether we should silently remove users who fail at this step instead of this
        final user = User(id: userId);
        data.add(FollowedUser(user));

        continue;
      }

      final user = User.fromJson(result.data!['user']);
      data.add(FollowedUser(user));
    }

    return data;
  }

  @override
  FutureOr<List<FollowedUser>> build() async {
    return _fetch();
  }

  Future<void> unfollowUser({required String id}) async {
    state = const AsyncValue.loading();

    final db = await DatabaseHelper().database;
    await db.delete(
      'followed_users',
      where: 'id = ?',
      whereArgs: [id],
    );

    state = await AsyncValue.guard(() async {
      return _fetch();
    });
  }

  Future<void> followUser({required String id}) async {
    state = const AsyncValue.loading();

    final db = await DatabaseHelper().database;
    await db.insert('followed_users', {'id': id}, conflictAlgorithm: ConflictAlgorithm.ignore);

    state = await AsyncValue.guard(() async {
      return _fetch();
    });
  }
}
