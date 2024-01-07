import 'dart:io';
import 'package:logging/logging.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
// ignore: library_prefixes
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

part 'oauth.g.dart';

// TODO: Migrate these values to a configuration file
final authorizationEndpoint = Uri.parse('https://start.gg/oauth/authorize');
final tokenEndpoint = Uri.parse('https://api.start.gg/oauth/access_token');
const identifier = '55';
const secret = 'd620f0c7911794528a592cf0e0f4c4dbff032626c121427aca6fa8f25a57bca6';
final redirectUrl = Uri.parse('startgg-ss23://login-callback');

// TODO: Where do we specify the refresh URL??????
// Refresh URL: https://api.start.gg/oauth/refresh

/// A file in which the users credentials are stored persistently. If the server
/// issues a refresh token allowing the client to refresh outdated credentials,
/// these may be valid indefinitely, meaning the user never has to
/// re-authenticate.
const credentialsPath = 'credentials.json';

@riverpod
class OAuthToken extends _$OAuthToken {
  final _log = Logger('OAuthToken');
  oauth2.AuthorizationCodeGrant? _grant;

  @override
  FutureOr<String> build() async {
    // TODO: Verify if this is a secure location for credentials on modern Android
    final appDirectory = await getApplicationDocumentsDirectory();
    final credentialsFile = File(Path.join(appDirectory.path, credentialsPath));

    final exists = credentialsFile.existsSync();

    // If the OAuth2 credentials have already been saved from a previous run, we just want to reload them.
    if (exists) {
      _log.fine('Retrieved saved credentials');
      final credentials = oauth2.Credentials.fromJson(await credentialsFile.readAsString());
      if (credentials.isExpired && credentials.canRefresh) {
        _log.fine('Refreshing expired credentials');
        final candidateClient = oauth2.Client(credentials, identifier: identifier, secret: secret);
        try {
          await candidateClient.refreshCredentials();
        } catch (e) {
          _log.warning('Failed to refresh credentials, despite having a valid refresh token. $e');
          // Any errors are this stage indicate we just need to start again with authentication
          return '';
        }
        // If we got here, it means we didn't have an error during the refresh, meaning the new credentials should be fine to use!
        final client = candidateClient;

        // Finally, save these new credentials so they're available for next time
        await saveNewCredentials(client.credentials);
        return client.credentials.accessToken;
      }

      if (!credentials.isExpired) {
        _log.fine('Using saved credentials');
        final client = oauth2.Client(credentials, identifier: identifier, secret: secret);
        return client.credentials.accessToken;
      }

      _log.fine('Saved credentials have expired: ${credentials.isExpired} - ${credentials.expiration}');
    }

    return '';
  }

  Future<void> authenticate() async {
    // Begin by changing our state to loading so the UI understands what we're doing (and doesn't try to run authenticate again)
    // TODO: Do we need a guard in here (e.g. verify that we're not already in the loading state?)
    state = const AsyncValue.loading();

    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    _grant = oauth2.AuthorizationCodeGrant(identifier, authorizationEndpoint, tokenEndpoint, secret: secret, onCredentialsRefreshed: saveNewCredentials);

    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    final authorizationUrl = _grant!.getAuthorizationUrl(redirectUrl, scopes: ['user.identity']);

    // Redirect the resource owner to the authorization URL. Once the resource
    // owner has authorized, they'll be redirected to `redirectUrl` with an
    // authorization code.
    await redirect(authorizationUrl);
    await listen();
  }

  Future<void> finish(Uri responseUrl) async {
    // Ensure that the WebView is closed at this point
    await closeInAppWebView();
    
    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    final client = await _grant!.handleAuthorizationResponse(responseUrl.queryParameters);

    state = await AsyncValue.guard(() async {
      return client.credentials.accessToken;
    });

    // We can continue to save the credentials now
    await saveNewCredentials(client.credentials);
  }

  Future<void> saveNewCredentials(oauth2.Credentials creds) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final credentialsFile = File(Path.join(appDirectory.path, credentialsPath));
    await credentialsFile.writeAsString(creds.toJson());
    _log.fine('Saved credentials');
  }

  Future<void> redirect(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _log.severe('Unable to launch URI: {$url}');
    }
  }

  Future<void> listen() async {
    uriLinkStream.listen((Uri? uri) {
      if (uri.toString().startsWith(redirectUrl.toString())) {
        finish(uri!);
      } else {
        // We recieved a redirect that we didn't expect! We should log this
        _log.warning('Recieved unexpected URI: {$uri}');
      }
    });
  }
}
