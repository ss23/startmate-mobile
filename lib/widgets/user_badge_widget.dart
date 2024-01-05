import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:startmate/user.dart';

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
            SizedBox(
                height: 100,
                width: 100,
                child: user.profileImage!.isNotEmpty ? CachedNetworkImage(
                  imageUrl: user.profileImage!,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 50,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => const CircularProgressIndicator(),
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
