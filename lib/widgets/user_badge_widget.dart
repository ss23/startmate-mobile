import 'package:flutter/material.dart';
import 'package:start_gg_app/user.dart';

class UserBadgeWidget extends StatelessWidget {
  final User user;

  const UserBadgeWidget(this.user, {super.key});

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
                child: Image.network(
                  user.profileImage!,
                )),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(children: [
                Text(user.name!),
                ElevatedButton(
                  onPressed:() { },
                  child: const Text("Unfollow"),
                ),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
