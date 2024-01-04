import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/widgets/loading_widget.dart';

class OnboardingPage extends ConsumerWidget {
  OnboardingPage({super.key});
  final log = Logger('OnboardingPage');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oAuthToken = ref.watch(oAuthTokenProvider);

    final candidateToken = oAuthToken.unwrapPrevious();

    if (candidateToken.hasValue && candidateToken.value != null && candidateToken.value!.isNotEmpty) {
      log.info("Redirecting away from onboarding");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const LoadingWidget(reason: "Authenticated successfully! Redirecting back.");
    }

    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
                "To use this application, you need to authenticate using start.gg. Click the following button to launch a browser and authorize your account. You will be redirected back here when finished.")),
        FilledButton(
            onPressed: () {
              ref.read(oAuthTokenProvider.notifier).authenticate();
            },
            child: const Text("Authenticate")),
      ]),
    );
  }
}
