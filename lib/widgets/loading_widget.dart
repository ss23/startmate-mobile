import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({required this.reason, super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const Padding(
              padding: EdgeInsets.all(8),
            ),
            Text(reason),
          ],
        ),
      ),
    );
  }
}
