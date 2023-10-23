import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:start_gg_app/helpers/oauth.dart';
import 'package:start_gg_app/screens/base.dart';
import 'package:start_gg_app/controllers/appstate_controller.dart';

void main() {
  // Configure logging
  if (kDebugMode) Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppStateController()),
        ChangeNotifierProvider(create: (context) => OAuthToken()),
      ],
      child: MaterialApp(
        home: const BasePage(),
        theme: ThemeData(
          useMaterial3: true,
        ),
      )));
}
