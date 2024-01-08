import 'package:circular_buffer/circular_buffer.dart';
import 'package:logging/logging.dart';

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

  static List<String> getLogs() {
    return logBuffer.toList();
  }
}
