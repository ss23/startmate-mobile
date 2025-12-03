import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/helpers/logger.dart';
import 'package:startmate/l10n/app_localizations.dart';
import 'package:startmate/screens/base.dart';

void main() {
  // Configure logging
  LoggerHelper.init();

  runApp(
    const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'), // English
        ],
        home: BasePage(),
      ),
    ),
  );
}
