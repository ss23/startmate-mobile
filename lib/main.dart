import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startmate/helpers/logger.dart';
import 'package:startmate/screens/base.dart';

void main() {
  // Configure logging
  LoggerHelper.init();
  
  runApp(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        home: const BasePage(),
        theme: ThemeData(
          useMaterial3: true,
        ),
      ),
    ),
  );
}
