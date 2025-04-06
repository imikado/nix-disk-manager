import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Commands/system_commands.dart';
import 'package:nix_disk_manager/Entity/disk_entity.dart';

class DiskView extends StatefulWidget {
  final Function handleGoToHome;
  final String diskSelected;

  const DiskView({
    super.key,
    required this.handleGoToHome,
    required this.diskSelected,
  });

  @override
  State<DiskView> createState() => _DiskViewState();
}

class _DiskViewState extends State<DiskView> {
  List<DiskEntity> stateDiskList = [];

  @override
  void initState() {
    super.initState();

    SystemCommands diskCommand = SystemCommands();

    diskCommand.listDisk().then((diskList) {
      setState(() {
        stateDiskList = diskList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: () {
                          widget.handleGoToHome();
                        }),
                    Text('Disque sélectionné : ${widget.diskSelected}')
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Expanded(child: SizedBox())
              ],
            )));
  }
}
