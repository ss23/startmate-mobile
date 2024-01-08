import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:startmate/helpers/logger.dart';

Future<void> shareLog() async {
  final log = Logger('shareLog');

  final logPath = await LoggerHelper.getLogFile();

  log.info('Exporting logs: $logPath');
  await Share.shareXFiles([XFile(logPath)]);
}
