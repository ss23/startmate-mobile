import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      log.info('Redirecting away from onboarding');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return LoadingWidget(reason: AppLocalizations.of(context)!.authenticateSuccessRedirect);
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(AppLocalizations.of(context)!.authenticateRequest),
          ),
          FilledButton(
            onPressed: () {
              ref.read(oAuthTokenProvider.notifier).authenticate();
            },
            child: Text(AppLocalizations.of(context)!.authenticateRequestLabel),
          ),
        ],
      ),
    );
  }
}
