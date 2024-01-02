import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/controllers/datastate.dart';
import 'package:start_gg_app/controllers/follow_user_search_controller.dart';
import 'package:start_gg_app/controllers/followed_users_controller.dart';
import 'package:start_gg_app/widgets/user_badge_widget.dart';

class FollowUserPage extends StatelessWidget {
  const FollowUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Follow a user'),
        ),
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => FollowUserSearchController()),
            ChangeNotifierProvider(create: (context) => FollowedUsersController(context: context)),
          ],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<FollowUserSearchController>(
              builder: (BuildContext context, FollowUserSearchController controller, Widget? _) {
                return Column(
                  children: [
                    TextField(
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search for a user',
                      ),
                      onSubmitted: (search) => controller.fetch(search),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.length + 1,
                        itemBuilder: (BuildContext context, int i) {
                          if (i == 0) {
                            if (controller.state == DataState.fetching) {
                              return const Center(child: CircularProgressIndicator());
                            } else if ((controller.state == DataState.fetched || controller.state == DataState.endOfData) && controller.length == 0) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                    "No results found."),
                              );
                            } else {
                              return Container(); // Empty placeholder for refreshing indicator.
                            }
                          }
                          return UserBadgeWidget(controller[i - 1],
                          actions: [
                            Consumer<FollowedUsersController>(
                              builder: (BuildContext context, FollowedUsersController usersController, Widget? _) => ElevatedButton(
                                onPressed: () {
                                  usersController.followUser(context: context, id: usersController[i - 1].user.id!);
                                  Navigator.pop(context);
                                },
                                child: const Text("Follow"),
                              ),
                            ),
                          ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }
}
