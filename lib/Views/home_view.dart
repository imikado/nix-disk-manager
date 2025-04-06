import 'package:flutter/material.dart';
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
      ElevatedButton.icon(
          label: Text(LocalizationApi().tr('start')),
          onPressed: handleGoToDiskList,
          icon: Icon(Icons.start))
    ]));
  }
}
