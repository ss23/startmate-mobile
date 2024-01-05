import 'package:flutter/material.dart';
import 'package:startmate/screens/follow_user.dart';

class FollowedEventsFAB extends FloatingActionButton {
  FollowedEventsFAB({required BuildContext context, super.key})
      : super(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FollowUserPage()),
            );
          },
          child: const Icon(Icons.add),
        );
  //FollowedEventsFAB({super.key}) : super.extended(onPressed: () { }, icon: const Icon(Icons.add), label: const Text('Follow a user'), );
}
