import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String reason;

  const LoadingWidget({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Text(reason),
          ]),
        ),
      );
  }
}