import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path_provider/path_provider.dart';
// ignore: library_prefixes
import 'package:path/path.dart' as Path;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

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

class OAuthToken extends ChangeNotifier {
  final log = Logger('OAuthToken');
  
  oauth2.Client? client;
  oauth2.AuthorizationCodeGrant? grant;
  bool needToAuthenticate = false;

  OAuthToken() {
    init();
  }

  init() async {
    // TODO: Verify if this is a secure location for credentials on modern Android
    final appDirectory = await getApplicationDocumentsDirectory();
    final credentialsFile = File(Path.join(appDirectory.path, credentialsPath));

    final exists = await credentialsFile.exists();
    // DEBUG: Pretend it doesn't exist
    //final exists = false;

    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (exists) {
      log.fine("Retrieved saved credentials");
      var credentials = oauth2.Credentials.fromJson(await credentialsFile.readAsString());
      if (credentials.isExpired && credentials.canRefresh) {
        log.fine("Refreshing expired credentials");
        var candidateClient = oauth2.Client(credentials, identifier: identifier, secret: secret);
        try {
          await candidateClient.refreshCredentials();
        } catch (e) {
          log.warning("Failed to refresh credentials, despite having a valid refresh token");
          log.warning(e);
          // Any errors are this stage indicate we just need to start again with authentication
          needToAuthenticate = true;
          notifyListeners();
          return;
        }
        // If we got here, it means we didn't have an error during the refresh, meaning the new credentials should be fine to use!
        client = candidateClient;
        notifyListeners();
        // Finally, save these new credentials so they're available for next time
        saveNewCredentials(client!.credentials);
        return;
      }

      if (!credentials.isExpired) {
        log.fine("Using saved credentials");
        client = oauth2.Client(credentials, identifier: identifier, secret: secret);
        // TODO: How do we set "onCredentialsRefreshed" here to ensure refreshed credentials are saved appropriately?
        notifyListeners();
        return;
      }

      log.fine("Saved credentials have expired: ${credentials.expiration}");
    }

    needToAuthenticate = true;
    notifyListeners();
  }

  authenticate() async {
    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    grant = oauth2.AuthorizationCodeGrant(identifier, authorizationEndpoint, tokenEndpoint, secret: secret, onCredentialsRefreshed: (p0) => saveNewCredentials(p0));

    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    var authorizationUrl = grant!.getAuthorizationUrl(redirectUrl, scopes: ['user.identity']);

    // Redirect the resource owner to the authorization URL. Once the resource
    // owner has authorized, they'll be redirected to `redirectUrl` with an
    // authorization code.
    await redirect(authorizationUrl);
    await listen();
  }

  finish(Uri responseUrl) async {
    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    client = await grant!.handleAuthorizationResponse(responseUrl.queryParameters);
    needToAuthenticate = false; // Reset this state, in case we need to redirect again in future
    notifyListeners();
    // We can continue to save the credentials now, but we don't need to block the UI while doing this, so we notify first
    saveNewCredentials(client!.credentials);
  }

  saveNewCredentials(oauth2.Credentials creds) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final credentialsFile = File(Path.join(appDirectory.path, credentialsPath));
    await credentialsFile.writeAsString(creds.toJson());
    log.fine("Saved credentials");
  }

  redirect(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      log.severe("Unable to launch URI: {$url}");
    }
  }

  listen() async {
    uriLinkStream.listen((Uri? uri) {
      if (uri.toString().startsWith(redirectUrl.toString())) {
        finish(uri!);
      } else {
        // We recieved a redirect that we didn't expect! We should log this
        log.warning("Recieved unexpected URI: {$uri}");
      }
    });
  }

  reauthenticate() async {
    // Force the user to reauthenticate, such as in the event of an invalid token error
    client = null;
    grant = null;
    needToAuthenticate = true;
    notifyListeners();
  }
}