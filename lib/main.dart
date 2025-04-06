import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nix_disk_manager/Commands/system_commands.dart';
import 'package:nix_disk_manager/nix_disk_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'package:nix_disk_manager/Api/localization_api.dart';
import 'package:window_manager/window_manager.dart';

final _log = Logger('Main');

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--version')) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    print('Version: ${packageInfo.version}');
    exit(0);
  }

  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  String appDocumentsDirPath = appDocumentsDir.path;

  Directory documentsTargetDirectory =
      Directory(p.join(appDocumentsDirPath, "NixDiskManager"));

  if (!documentsTargetDirectory.existsSync()) {
    await documentsTargetDirectory.create();
  }

  _log.info('Checking /etc/nixos contents:');
  ProcessResult processResult = Process.runSync('ls', ['/etc/nixos']);
  _log.info('\n${processResult.stdout}\n');

  List<String> binaryList = [
    'disk_list.sh',
    'check_run_as_root.sh',
    'initial_clean_and_regenerate.sh',
    'show_partition_of_disk_selected.sh',
    'get_fs_and_uuid.sh',
    'create_nix_file.sh'
  ];

  bool debug = kDebugMode;

  for (String binaryLoop in binaryList) {
    File binaryFile = File('${documentsTargetDirectory.path}/$binaryLoop');
    if (!binaryFile.existsSync() || debug) {
      _log.info('Copying $binaryLoop');
      final bytes = await rootBundle.load('assets/bin/$binaryLoop');
      final targetFile = File('${documentsTargetDirectory.path}/$binaryLoop');
      await targetFile.writeAsBytes(bytes.buffer.asUint8List());
      _log.info('Finished copying $binaryLoop');
    }
  }

  SystemCommands(documentsTargetDirectory.path);

  await LocalizationApi().load('fr'); // Load French translations

  final AdaptiveThemeMode savedThemeMode =
      await AdaptiveTheme.getThemeMode() ?? AdaptiveThemeMode.light;

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1000, 600),
    minimumSize: Size(400, 450),
    skipTaskbar: false,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Nix disk manager',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  runApp(NixDiskManager(savedThemeMode: savedThemeMode));
}
