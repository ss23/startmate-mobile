import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:startmate/screens/base.dart';

void main() {
  // Configure logging
  if (kDebugMode) Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(ProviderScope(child: MaterialApp(
    home: const BasePage(),
    theme: ThemeData(
      useMaterial3: true,
    ),
  ),));
}
