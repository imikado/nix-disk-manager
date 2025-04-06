import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:nix_disk_manager/Api/localization_api.dart';

class HomeView extends StatelessWidget {
  final dynamic handleGoToDiskList;

  const HomeView({
    super.key,
    required this.handleGoToDiskList,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      SizedBox(
        height: 30,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(LocalizationApi().tr('home_text'))],
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
          width: 200,
          child: AdwButton.pill(
            onPressed: handleGoToDiskList,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text(LocalizationApi().tr('start')),
                  Icon(Icons.start_sharp)
                ]),
          ))
    ]));
  }
}
