import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/controllers/follow_user_search_controller.dart';
import 'package:startmate/controllers/followed_users_controller.dart';
import 'package:startmate/user.dart';
import 'package:startmate/widgets/user_badge_widget.dart';

class FollowUserPage extends ConsumerStatefulWidget {
  const FollowUserPage({super.key});

  @override
  ConsumerState<FollowUserPage> createState() => _FollowUserPageState();
}

class _FollowUserPageState extends ConsumerState<FollowUserPage> {
  String? searchQuery;

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<User>>? fetchUsers;

    if (searchQuery != null) {
      fetchUsers = ref.watch(fetchUsersProvider(searchQuery));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow a user'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              autocorrect: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search for a user',
              ),
              onSubmitted: (search) {
                setState(() {
                  searchQuery = search;
                });
              },
            ),
            const SizedBox(height: 10),
            if (fetchUsers != null)
              Expanded(
                child: switch (fetchUsers) {
                  AsyncData(:final value) => ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (BuildContext context, int i) {
                        return UserBadgeWidget(
                          value[i],
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                ref.read(followedUsersProvider.notifier).followUser(id: value[i].id!);
                                Navigator.pop(context);
                              },
                              child: const Text('Follow'),
                            ),
                          ],
                        );
                      },
                    ),
                  AsyncError(:final error) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('An error occured! Please try again or file a bug. $error'),
                    ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
          ],
        ),
      ),
    );
  }
}
