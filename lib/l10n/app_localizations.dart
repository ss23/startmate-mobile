import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Navigation label for the Registered page, the events the currently logged in user is signed up for
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get navigationRegistered;

  /// Navigation label for the Followed page, the events attended by users the currently logged in user follows
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get navigationFollowed;

  /// Navigation label for the Find page, such as events featured by start.gg
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get navigationFind;

  /// User-facing message when an error needs to be presented within the UI.
  ///
  /// In en, this message translates to:
  /// **'An error has occured. Please try again or report a bug. Details: {error}'**
  String genericError(String error);

  /// Label for the list of tournaments the logged in user is registered for
  ///
  /// In en, this message translates to:
  /// **'Registered Tournaments'**
  String get registeredTournamentsLabel;

  /// Text shown to the user when there are no tournaments they are currently registered for, in place of where tournaments would be
  ///
  /// In en, this message translates to:
  /// **'You aren\'t registered for any upcoming tournaments. As registration is not currently supported in this application, register on start.gg and come back here.'**
  String get registeredTournamentsEmpty;

  /// Briefly displayed message once credentials have been recieved from start.gg and a redirect to the Home of the application is in progress.
  ///
  /// In en, this message translates to:
  /// **'Authenticated successfully! Redirecting...'**
  String get authenticateSuccessRedirect;

  /// Message requesting the user complete authentication with start.gg to begin using the application
  ///
  /// In en, this message translates to:
  /// **'To use this application, you need to authenticate using start.gg. Click the following button to launch a browser and authorize your account. You will be redirected back here when finished.'**
  String get authenticateRequest;

  /// Button label to begin authentication with start.gg
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get authenticateRequestLabel;

  /// Briefly displayed message before application is redirected to the onboarding screen, in the case where the user is not currently logged in
  ///
  /// In en, this message translates to:
  /// **'Redirecting to onboarding'**
  String get authenticateRequestRedirect;

  /// Briefly displayed message while the application is verifying the oauth credentials saved or just obtained
  ///
  /// In en, this message translates to:
  /// **'Authenticating'**
  String get authenticateRequestPending;

  /// Short description shown to user when the application does not recieve any credentials after redirecting to the start.gg authorization page
  ///
  /// In en, this message translates to:
  /// **'No credentials were recieved from start.gg'**
  String get authenticateMissingCredentials;

  /// Further help shown to the user if they are shown the missing credentials error
  ///
  /// In en, this message translates to:
  /// **'You can try authorizing again (such as if you inadvertently clicked back or deny instead of authorize)'**
  String get authenticateMissingCredentialsHelp;

  /// Short description of the current application state while it is attempting to verify and save the credentials it recieved from start.gg
  ///
  /// In en, this message translates to:
  /// **'Saving credentials'**
  String get authenticateVerifyingCredentials;

  /// AppBar title for when an error occurs during authentication
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get authenticateError;

  /// Message shown to use when they click authorize and are being redirected to start.gg to complete authentication
  ///
  /// In en, this message translates to:
  /// **'Redirecting to start.gg'**
  String get authenticateRedirectStartgg;

  /// Text shown to the user when there are no users they are currently following, in place of where the followed users would be
  ///
  /// In en, this message translates to:
  /// **'Follow a user to see their events'**
  String get followUserEmpty;

  /// Button label to unfollow a user
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get followUserUnfollowLabel;

  /// Text shown to the user when there are no tournaments from users they are currently following, in place of where the tournaments would be
  ///
  /// In en, this message translates to:
  /// **'No upcoming tournaments found. Follow more people to see their tournaments'**
  String get followUserTournamentsEmpty;

  /// Label for the list of users the logged in user is following
  ///
  /// In en, this message translates to:
  /// **'Followed Users'**
  String get followUserUsersLabel;

  /// Label for the list of tournaments from users logged in user is following
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get followUserTournamentsLabel;

  /// Title for screen to follow a user
  ///
  /// In en, this message translates to:
  /// **'Follow a user'**
  String get followUserFollowLabel;

  /// Button label to search for a user to follow
  ///
  /// In en, this message translates to:
  /// **'Search for a user'**
  String get followUserSearchLabel;

  /// Button label to follow a user
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followUserButtonLabel;

  /// Text shown to the user when there are no users found from the search they performed
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get followUserUsersEmpty;

  /// Text shown to the user when there are no featured tournaments on start.gg. This is highly unlikely to ever occur, unless by error.
  ///
  /// In en, this message translates to:
  /// **'No featured events found'**
  String get findFeaturedEmpty;

  /// Label for the list of featured tournaments on the find page
  ///
  /// In en, this message translates to:
  /// **'Featured Tournaments'**
  String get findFeaturedLabel;

  /// Button that links to the form to register for a tournament
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get tournamentRegisterLabel;

  /// Text to indicate how many entrants are attending an event in a tournament
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entrant} other{{count} entrants}}'**
  String tournamentEventEntrantsText(num count);

  /// Button linking to page to view information about bracket for the event
  ///
  /// In en, this message translates to:
  /// **'Bracket'**
  String get tournamentBracketButton;

  /// Label for section of the bracket page showing the different brackets in the event. Internally, these are the Phases
  ///
  /// In en, this message translates to:
  /// **'Brackets'**
  String get bracketBracketLabel;

  /// Text to indicate how many entrants are participating in a given pool
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entrant} other{{count} entrants}}'**
  String bracketEntrantsText(num count);

  /// Text to indicate how many pool groups are in a pool
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pool} other{{count} pools}}'**
  String bracketPoolgroupsText(num count);

  /// Label for a phase group. The official start.gg web interface terms these Pools in English
  ///
  /// In en, this message translates to:
  /// **'Pool {phaseGroupLabel}'**
  String bracketPhaseGroupLabel(String phaseGroupLabel);

  /// When an event has only a single phase (such as a small local), instead of listing the single phase and making the user click, they are automatically redirected. This is the message briefly shown to the user when this happens.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to pools'**
  String get bracketPhaseRedirect;

  /// When a phase has only a single phasegroup (such as a small local), instead of listing the single phasegroup and making the user click, they are automatically redirected. This is the message briefly shown to the user when this happens.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to sets'**
  String get bracketPhaseGroupRedirect;

  /// Round score label for when a player is disqualified.
  ///
  /// In en, this message translates to:
  /// **'DQ'**
  String get bracketDisqualified;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
