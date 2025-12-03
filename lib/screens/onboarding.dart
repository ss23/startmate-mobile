import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:startmate/controllers/log_controller.dart';
import 'package:startmate/helpers/oauth.dart';
import 'package:startmate/l10n/app_localizations.dart';
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

    if (oAuthToken is AsyncError) {
      // This state is when we have been redirected, but more than 2 seconds have passed.
      // Most likely, this means the user clicked back or did not approve the authorization
      // This could also happen if a bug occurs related to handling the application specific URIs.
      switch (oAuthToken.error) {
        case 'redirected-to-startgg':
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.authenticateError),
              automaticallyImplyLeading: false,
              actions: const [
                IconButton(
                  icon: Icon(Icons.add_alert),
                  tooltip: 'Capture logs',
                  onPressed: shareLog,
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(AppLocalizations.of(context)!.authenticateMissingCredentials),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    AppLocalizations.of(context)!.authenticateMissingCredentialsHelp,
                    textAlign: TextAlign.center,
                  ),
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
        // This means that we recieved the credentials back from start.gg and are just verifying that they work before proceeding
        case 'verifying':
          return LoadingWidget(reason: AppLocalizations.of(context)!.authenticateVerifyingCredentials);
        default:
          return Text(AppLocalizations.of(context)!.genericError(oAuthToken.error!.toString()));
      }
    }

    // Loading here means that we are redirecting to start.gg
    if (oAuthToken is AsyncLoading) {
      return LoadingWidget(reason: AppLocalizations.of(context)!.authenticateRedirectStartgg);
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
