import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/controllers/follow_user_search_controller.dart';
import 'package:startmate/controllers/followed_users_controller.dart';
import 'package:startmate/l10n/app_localizations.dart';
import 'package:startmate/models/startgg/user.dart';
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
        title: Text(AppLocalizations.of(context)!.followUserFollowLabel),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              autocorrect: false,
              autofocus: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.followUserSearchLabel,
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
                  AsyncData(:final value) => (value.isEmpty)
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(AppLocalizations.of(context)!.followUserUsersEmpty),
                        )
                      : ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (BuildContext context, int i) {
                            return UserBadgeWidget(
                              value[i],
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(followedUsersProvider.notifier).followUser(id: value[i].id);
                                    Navigator.pop(context);
                                  },
                                  child: Text(AppLocalizations.of(context)!.followUserButtonLabel),
                                ),
                              ],
                            );
                          },
                        ),
                  AsyncError(:final error) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(AppLocalizations.of(context)!.genericError(error.toString())),
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
