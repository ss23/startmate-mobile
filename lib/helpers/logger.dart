import 'dart:io';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:logging/logging.dart';
// ignore: library_prefixes
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

const logPath = 'log.txt';

class LoggerHelper {
  // These lines can be very long, so limit their length to save memory
  // TODO: Enable and disable log retention to save further memory in production
  static final logBuffer = CircularBuffer<String>(100);

  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
      logBuffer.add('${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static Future<String> getLogFile() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final credentialsFile = File(Path.join(appDirectory.path, logPath));

    final sink = credentialsFile.openWrite();

    // Write a little bit of information about the device first
    sink.write(Platform.operatingSystem + Platform.lineTerminator);
    sink.write(Platform.operatingSystemVersion + Platform.lineTerminator);

    // Write out the logs
    for (final line in logBuffer) {
      sink.write(line + Platform.lineTerminator);
    }

    await sink.close();

    return credentialsFile.path;
  }
}
