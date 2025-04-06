import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Commands/system_commands.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';
import 'package:nix_disk_manager/Entity/partition_details_entity.dart';
import 'package:nix_disk_manager/Entity/partition_entity.dart';
import 'package:nix_disk_manager/Response/command_response.dart';
import 'package:nix_disk_manager/Views/Shared/width_space_component.dart';
import 'package:nix_disk_manager/Api/localization_api.dart';

class DiskSelectedView extends StatefulWidget {
  final bool isDebug;
  final Function handleGoToDiskList;
  final Function handleGoToNextPage;
  final String diskSelected;

  const DiskSelectedView({
    super.key,
    required this.isDebug,
    required this.handleGoToDiskList,
    required this.handleGoToNextPage,
    required this.diskSelected,
  });

  @override
  State<DiskSelectedView> createState() => _DiskSelectedViewState();
}

class _DiskSelectedViewState extends State<DiskSelectedView> {
  List<DiskEntity> stateDiskList = [];
  List<PartitionEntity> statePartitionList = [];
  PartitionEntity? statePartitionSelected;
  PartitionDetailsEntity? statePartitionDetailsSelected;

  DiskEntity? stateDiskSelected;

  ScrollController scrollController = ScrollController();

  final TextEditingController mountPointController = TextEditingController();

  bool stateDisplayMountPointButton = true;
  bool stateDisplayCircularMountPointButton = false;

  String stateMountPointMessage = '';

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() async {
    SystemCommands systemCommands = SystemCommands();

    systemCommands.listDisk().then((diskList) {
      for (DiskEntity diskLoop in diskList) {
        if (diskLoop.path == widget.diskSelected) {
          setState(() {
            stateDiskSelected = diskLoop;
          });

          loadPartition(diskLoop);
        }
      }
    });
  }

  void loadPartition(DiskEntity diskSelected) async {
    SystemCommands systemCommands = SystemCommands();

    systemCommands
        .listPartitionByDisk(diskSelected.path)
        .then((List<PartitionEntity> partitionList) {
      setState(() => statePartitionList = partitionList);
    });
  }

  void loadPartitionDetail(PartitionEntity partitionSelected) async {
    SystemCommands systemCommands = SystemCommands();
    systemCommands
        .getDetailPartitionFor(partitionSelected.name)
        .then((PartitionDetailsEntity partitionDetailEntity) {
      setState(() {
        statePartitionSelected = partitionSelected;
        statePartitionDetailsSelected = partitionDetailEntity;
      });
    });
  }

  void createMountPoint(String mountPath) async {
    SystemCommands systemCommands = SystemCommands();

    setState(() {
      stateDisplayCircularMountPointButton = true;
      stateDisplayMountPointButton = false;
    });

    String absoluteMountPoint = '/media/$mountPath';
    CommandResponse commandResponse =
        await systemCommands.createMountPointAndNixFile(
            statePartitionDetailsSelected!.fileSystem,
            absoluteMountPoint,
            statePartitionDetailsSelected!.uuid);

    if (commandResponse.status) {
      setState(() {
        stateDisplayCircularMountPointButton = false;
        stateMountPointMessage = commandResponse.message;
      });
    } else {
      setState(() {
        stateDisplayCircularMountPointButton = false;
        stateMountPointMessage = commandResponse.message;
      });
    }
  }

  void cancelCreateMountMoint() {
    setState(() {
      mountPointController.clear();
      stateDisplayCircularMountPointButton = false;
      stateDisplayMountPointButton = true;
      stateMountPointMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                widget.handleGoToDiskList();
              }),
          stateDiskSelected == null
              ? const CircularProgressIndicator()
              : Text(LocalizationApi().tr('disk_selected_disk', {
                  'diskPath': stateDiskSelected!.path,
                  'diskSize': stateDiskSelected!.size
                }))
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      if (statePartitionList.isNotEmpty)
        statePartitionSelected == null
            ? Row(
                children: [
                  Text(LocalizationApi().tr('disk_selected_select_partition')),
                ],
              )
            : Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          statePartitionSelected = null;
                        });
                      }),
                  Text(
                      LocalizationApi().tr('disk_selected_partition_selected')),
                ],
              ),
      statePartitionSelected == null
          ? Expanded(
              child: ListView(
                  children:
                      statePartitionList.map((PartitionEntity partitionLoop) {
              return Card(
                  child: ListTile(
                      onTap: () {
                        loadPartitionDetail(partitionLoop);
                      },
                      title: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(LocalizationApi().tr('disk_selected_name')),
                              Text(partitionLoop.name),
                            ],
                          ),
                          const WidthSpaceComponent(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(LocalizationApi().tr('disk_selected_size')),
                              Text(partitionLoop.size),
                            ],
                          ),
                          const WidthSpaceComponent(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  LocalizationApi().tr('disk_selected_format')),
                              Text(partitionLoop.format),
                            ],
                          ),
                        ],
                      )));
            }).toList()))
          : Expanded(
              child: Column(
              children: [
                ListTile(
                    title: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LocalizationApi().tr('disk_selected_name')),
                        Text(statePartitionSelected!.name),
                      ],
                    ),
                    const WidthSpaceComponent(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LocalizationApi().tr('disk_selected_size')),
                        Text(statePartitionSelected!.size),
                      ],
                    ),
                    const WidthSpaceComponent(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LocalizationApi().tr('disk_selected_format')),
                        Text(statePartitionSelected!.format),
                      ],
                    ),
                  ],
                )),
                if (statePartitionDetailsSelected != null)
                  ListTile(
                    title: Text(LocalizationApi().tr('disk_selected_details')),
                  ),
                if (statePartitionDetailsSelected != null)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(30, 5, 4, 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(LocalizationApi()
                                  .tr('disk_selected_file_system')),
                              Text(statePartitionDetailsSelected!.fileSystem),
                            ],
                          ),
                          Row(
                            children: [
                              Text(LocalizationApi().tr('disk_selected_uuid')),
                              Text(statePartitionDetailsSelected!.uuid),
                            ],
                          ),
                          Row(
                            children: [
                              Text(LocalizationApi()
                                  .tr('disk_selected_mount_point_prompt')),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: mountPointController,
                                  decoration: InputDecoration(
                                    hintText: LocalizationApi()
                                        .tr('disk_selected_mount_point_hint'),
                                  ),
                                ),
                              ),
                              if (stateDisplayMountPointButton)
                                ElevatedButton(
                                  onPressed: () {
                                    createMountPoint(mountPointController.text);
                                  },
                                  child: Text(LocalizationApi()
                                      .tr('disk_selected_validate')),
                                ),
                              if (stateDisplayCircularMountPointButton)
                                const CircularProgressIndicator(),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                stateMountPointMessage,
                                style: const TextStyle(color: Colors.redAccent),
                              )
                            ],
                          ),
                          if (stateMountPointMessage.isNotEmpty)
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    cancelCreateMountMoint();
                                  },
                                  label: Text(LocalizationApi()
                                      .tr('disk_selected_cancel_retry')),
                                )
                              ],
                            )
                        ],
                      ))
              ],
            ))
    ]);
  }
}
