// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationRegistered => 'Registered';

  @override
  String get navigationFollowed => 'Followed';

  @override
  String get navigationFind => 'Find';

  @override
  String genericError(String error) {
    return 'An error has occured. Please try again or report a bug. Details: $error';
  }

  @override
  String get registeredTournamentsLabel => 'Registered Tournaments';

  @override
  String get registeredTournamentsEmpty =>
      'You aren\'t registered for any upcoming tournaments. As registration is not currently supported in this application, register on start.gg and come back here.';

  @override
  String get authenticateSuccessRedirect =>
      'Authenticated successfully! Redirecting...';

  @override
  String get authenticateRequest =>
      'To use this application, you need to authenticate using start.gg. Click the following button to launch a browser and authorize your account. You will be redirected back here when finished.';

  @override
  String get authenticateRequestLabel => 'Authenticate';

  @override
  String get authenticateRequestRedirect => 'Redirecting to onboarding';

  @override
  String get authenticateRequestPending => 'Authenticating';

  @override
  String get authenticateMissingCredentials =>
      'No credentials were recieved from start.gg';

  @override
  String get authenticateMissingCredentialsHelp =>
      'You can try authorizing again (such as if you inadvertently clicked back or deny instead of authorize)';

  @override
  String get authenticateVerifyingCredentials => 'Saving credentials';

  @override
  String get authenticateError => 'Error';

  @override
  String get authenticateRedirectStartgg => 'Redirecting to start.gg';

  @override
  String get followUserEmpty => 'Follow a user to see their events';

  @override
  String get followUserUnfollowLabel => 'Unfollow';

  @override
  String get followUserTournamentsEmpty =>
      'No upcoming tournaments found. Follow more people to see their tournaments';

  @override
  String get followUserUsersLabel => 'Followed Users';

  @override
  String get followUserTournamentsLabel => 'Tournaments';

  @override
  String get followUserFollowLabel => 'Follow a user';

  @override
  String get followUserSearchLabel => 'Search for a user';

  @override
  String get followUserButtonLabel => 'Follow';

  @override
  String get followUserUsersEmpty => 'No users found';

  @override
  String get findFeaturedEmpty => 'No featured events found';

  @override
  String get findFeaturedLabel => 'Featured Tournaments';

  @override
  String get tournamentRegisterLabel => 'Register';

  @override
  String tournamentEventEntrantsText(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString entrants',
      one: '1 entrant',
    );
    return '$_temp0';
  }

  @override
  String get tournamentBracketButton => 'Bracket';

  @override
  String get bracketBracketLabel => 'Brackets';

  @override
  String bracketEntrantsText(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString entrants',
      one: '1 entrant',
    );
    return '$_temp0';
  }

  @override
  String bracketPoolgroupsText(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pools',
      one: '1 pool',
    );
    return '$_temp0';
  }

  @override
  String bracketPhaseGroupLabel(String phaseGroupLabel) {
    return 'Pool $phaseGroupLabel';
  }

  @override
  String get bracketPhaseRedirect => 'Redirecting to pools';

  @override
  String get bracketPhaseGroupRedirect => 'Redirecting to sets';

  @override
  String get bracketDisqualified => 'DQ';
}
