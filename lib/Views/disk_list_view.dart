import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Commands/system_commands.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';
import 'package:nix_disk_manager/Views/Shared/width_space_component.dart';
import 'package:nix_disk_manager/Api/localization_api.dart';

class DiskListView extends StatefulWidget {
  final bool isDebug;
  final Function handleGoToDisk;

  const DiskListView({
    super.key,
    required this.isDebug,
    required this.handleGoToDisk,
  });

  @override
  State<DiskListView> createState() => _DiskListViewState();
}

class _DiskListViewState extends State<DiskListView> {
  List<DiskEntity> stateDiskList = [];

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() async {
    SystemCommands diskCommand = SystemCommands();

    diskCommand.listDisk().then((diskList) {
      setState(() {
        stateDiskList = diskList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [Text(LocalizationApi().tr('disk_list_select_disk'))],
        ),
        const SizedBox(height: 15),
        Expanded(
          child: ListView(
            children: stateDiskList.map((stateDiskLoop) {
              return Card(
                child: ListTile(
                  onTap: () {
                    widget.handleGoToDisk(stateDiskLoop.path);
                  },
                  title: Row(
                    children: [
                      const Icon(Icons.storage),
                      const WidthSpaceComponent(),
                      Text(stateDiskLoop.path),
                      const WidthSpaceComponent(),
                      Text(stateDiskLoop.size)
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
