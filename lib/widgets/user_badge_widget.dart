import 'package:flutter/material.dart';
import 'package:start_gg_app/user.dart';

class UserBadgeWidget extends StatelessWidget {
  final User user;
  final List<Widget> actions;

  const UserBadgeWidget(this.user, {super.key, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 230,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(children: [
            ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                child: user.profileImage!.isNotEmpty ? Image.network(
                  user.profileImage!,
                ) : Container(),
                ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(children: [
                Text(user.name!),
                for (var widget in actions) widget,
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
