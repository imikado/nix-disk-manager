import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';
import 'package:nix_disk_manager/Entity/partition_entity.dart';
import 'package:nix_disk_manager/Entity/partition_details_entity.dart';
import 'package:nix_disk_manager/Response/command_response.dart';
import 'package:logging/logging.dart';
import 'package:nix_disk_manager/Api/localization_api.dart';

class SystemCommands {
  static final _log = Logger('SystemCommands');
  bool isDebug = true;

  static const String successPattern = 'success';

  static const String flatpakSpawnBin = 'flatpak-spawn';

  late String documentsPath;
  String commandDiskList = 'disk_list.sh';
  String commandCheckRunAsRoot = 'check_run_as_root.sh';
  String commandCleanAndRegenerate = 'initial_clean_and_regenerate.sh';
  String commandShowPartitionForDisk = 'show_partition_of_disk_selected.sh';
  String commandGetPartionDetail = 'get_fs_and_uuid.sh';
  String commandCreateFile = 'create_nix_file.sh';

  static final SystemCommands _singleton = SystemCommands._internal();

  factory SystemCommands([String? newDocumentsPath]) {
    if (newDocumentsPath != null) {
      _singleton.documentsPath = newDocumentsPath;

      if (kReleaseMode) {
        _singleton.isDebug = false;
      } else {
        Logger.root.level = Level.ALL;
        Logger.root.onRecord.listen((record) {
          debugPrint('${record.level.name}: ${record.time}: ${record.message}');
        });
      }
    }
    return _singleton;
  }

  String getPath(String binaryPath) {
    return '$documentsPath/$binaryPath';
  }

  SystemCommands._internal();

  ProcessResult runSync(String command, List<String> argumentList) {
    List<String> newArgumentList = [command];

    for (String argumentLoop in argumentList) {
      newArgumentList.add(argumentLoop);
    }

    return Process.runSync('bash', newArgumentList);
  }

  ProcessResult privilegedRunSync(String command, List<String> argumentList) {
    List<String> newArgumentList = ['bash', command];

    for (String argumentLoop in argumentList) {
      newArgumentList.add(argumentLoop);
    }

    return Process.runSync('pkexec', newArgumentList);
  }

  Future<List<DiskEntity>> listDisk() async {
    ProcessResult result = runSync(getPath(commandDiskList), []);
    _log.info(LocalizationApi().tr('system_commands_log_listing_disks'));

    List<String> rawLineList = result.stdout.toString().split('\n');
    List<DiskEntity> diskList = [];

    for (String lineLoop in rawLineList) {
      if (lineLoop.trim().length > 3) {
        lineLoop = lineLoop.trim().replaceAll(RegExp(r'\s+'), ' ');
        List<String> lineDetailList = lineLoop.trim().split(' ');
        diskList
            .add(DiskEntity(path: lineDetailList[0], size: lineDetailList[1]));
        _log.fine(LocalizationApi().tr('system_commands_log_found_disk',
            {'disk': lineDetailList[0], 'size': lineDetailList[1]}));
      }
    }

    return diskList;
  }

  Future<List<PartitionEntity>> listPartitionByDisk(String diskPath) async {
    _log.info(LocalizationApi()
        .tr('system_commands_log_listing_parts', {'disk': diskPath}));
    ProcessResult result =
        runSync(getPath(commandShowPartitionForDisk), [diskPath]);

    List<String> rawLineList = result.stdout.toString().split('\n');
    List<PartitionEntity> partitionList = [];

    for (String lineLoop in rawLineList) {
      if (lineLoop.trim().length > 3) {
        lineLoop = lineLoop.trim().replaceAll(RegExp(r'\s+'), ' ');
        List<String> lineDetailList = lineLoop.trim().split(' ');

        String formatFound =
            LocalizationApi().tr('system_commands_format_unknown');
        if (lineDetailList.length > 2) {
          formatFound = lineDetailList[2];
        }

        _log.fine(LocalizationApi().tr('system_commands_log_found_part', {
          'name': lineDetailList[0],
          'size': lineDetailList[1],
          'format': formatFound
        }));
        partitionList.add(PartitionEntity(
            name: lineDetailList[0],
            size: lineDetailList[1],
            format: formatFound));
      }
    }

    return partitionList;
  }

  Future<PartitionDetailsEntity> getDetailPartitionFor(
      String partitionName) async {
    _log.info(LocalizationApi()
        .tr('system_commands_log_listing_parts', {'disk': partitionName}));
    ProcessResult result =
        runSync(getPath(commandGetPartionDetail), ["/dev/$partitionName"]);

    List<String> rawLineList = result.stdout.toString().split('\n');

    for (String lineLoop in rawLineList) {
      if (lineLoop.trim().length > 3) {
        List<String> lineDetailList = lineLoop.trim().split('|');

        if (lineDetailList[0] == successPattern) {
          _log.fine(LocalizationApi().tr('system_commands_log_part_details',
              {'fs': lineDetailList[1], 'uuid': lineDetailList[2]}));
          return PartitionDetailsEntity(
              fileSystem: lineDetailList[1], uuid: lineDetailList[2]);
        }
      }
    }

    String errorMessage = LocalizationApi()
        .tr('system_commands_error_no_details', {'partition': partitionName});
    _log.warning(errorMessage);
    String unknown = LocalizationApi().tr('system_commands_format_unknown');
    return PartitionDetailsEntity(fileSystem: unknown, uuid: unknown);
  }

  void debug(String text) {
    if (isDebug) {
      _log.fine(text);
    }
  }

  void error(String text) {
    _log.severe(text);
  }

  Future<CommandResponse> createMountPointAndNixFile(
      String fsType, String mountPoint, String uuid) async {
    String command =
        '/bin/bash ${getPath(commandCreateFile)} $fsType $mountPoint $uuid';
    _log.info(LocalizationApi()
        .tr('system_commands_log_executing', {'command': command}));

    try {
      ProcessResult result = privilegedRunSync(
          getPath(commandCreateFile), [fsType, mountPoint, uuid]);
      String errorResult = result.stderr.toString();

      if (errorResult.isNotEmpty) {
        String errorMessage = LocalizationApi()
            .tr('system_commands_error_creating_file', {'error': errorResult});
        _log.severe(errorMessage);
        return CommandResponse(status: false, message: errorMessage);
      }

      String rawLine = result.stdout.toString();
      _log.info(LocalizationApi()
          .tr('system_commands_log_nix_result', {'result': rawLine}));

      if (rawLine.contains('success')) {
        return CommandResponse(
            status: true,
            message: LocalizationApi().tr('disk_selected_success_message'));
      }

      String errorMessage =
          LocalizationApi().tr('system_commands_error_unknown');
      _log.warning(errorMessage);
      return CommandResponse(status: false, message: errorMessage);
    } catch (e) {
      String errorMessage = LocalizationApi()
          .tr('system_commands_error_creating_file', {'error': e.toString()});
      _log.severe(errorMessage);
      return CommandResponse(status: false, message: errorMessage);
    }
  }
}
