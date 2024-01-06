import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:startmate/models/startgg/user.dart';

class UserBadgeWidget extends StatelessWidget {
  const UserBadgeWidget(this.user, {super.key, this.actions = const []});

  final User user;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 230,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: (user.image('profile') != null)
                    ? CachedNetworkImage(
                        imageUrl: user.image('profile')!.url,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 50,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                      )
                    : Container(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    children: [
                      Expanded(child: Center(child: Text((user.player != null && user.player!.gamerTag != null) ? user.player!.gamerTag! : ((user.name != null) ? user.name! : 'Error - unknown name')))),
                      for (final widget in actions) widget,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
