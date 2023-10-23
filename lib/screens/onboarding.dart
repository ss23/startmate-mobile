import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/helpers/oauth.dart';
import 'package:start_gg_app/widgets/loading_widget.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final oAuthToken = context.watch<OAuthToken>();
    if (oAuthToken.client != null) {
      // Redirect to the onboarding page to prompt the user to login
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // We use SchedulerBinding because we cannot change the page during a build
        Navigator.pop(context);
      });
      return const LoadingWidget(reason: "Redirecting to onboarding");
    }

    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
                "To use this application, you need to authenticate using start.gg. Click the following button to launch a browser and authorize your account. You will be redirected back here when finished.")),
        FilledButton(onPressed: () {
          oAuthToken.authenticate();
        }, child: const Text("Authenticate")),
      ]),
    );
  }
}
