import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:adwaita/adwaita.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Api/localization_api.dart';
import 'package:nix_disk_manager/Layout/default_layout.dart';
import 'package:nix_disk_manager/Views/disk_list_view.dart';
import 'package:nix_disk_manager/Views/disk_selected_view.dart';
import 'package:nix_disk_manager/Views/home_view.dart';

class NixDiskManager extends StatefulWidget {
  final AdaptiveThemeMode savedThemeMode;

  const NixDiskManager({super.key, required this.savedThemeMode});

  @override
  NixDiskManagerState createState() => NixDiskManagerState();
}

class NixDiskManagerState extends State<NixDiskManager> {
  String statePageSelected = constPageHome;

  String stateLanguageSelected = LocalizationApi().languageCode;

  static const String constPageHome = 'home';
  static const String constPageDiskList = 'diskList';
  static const String constPageDiskSelected = 'diskSelected';

  String stateDiskSelected = '';

  bool stateIsDebug = true;

  @override
  void initState() {
    super.initState();

    if (kReleaseMode) {
      setState(() => stateIsDebug = false);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: AdwaitaThemeData.light(),
        dark: AdwaitaThemeData.dark(),
        initial: widget.savedThemeMode,
        builder: (theme, darkTheme) => MaterialApp(
            theme: theme,
            darkTheme: darkTheme,
            home: Navigator(onDidRemovePage: (page) => false, pages: [
              if (statePageSelected == constPageDiskList)
                MaterialPage(
                    key: const ValueKey(constPageDiskList),
                    child: DefaultLayout(
                        handleSetLanguageCode: setLanguageCode,
                        languageSelected: stateLanguageSelected,
                        content: DiskListView(
                          isDebug: stateIsDebug,
                          handleGoToDisk: goToDiskSelected,
                        )))
              else if (statePageSelected == constPageDiskSelected)
                MaterialPage(
                    key: const ValueKey(constPageDiskList),
                    child: DefaultLayout(
                        handleSetLanguageCode: setLanguageCode,
                        languageSelected: stateLanguageSelected,
                        content: DiskSelectedView(
                          isDebug: stateIsDebug,
                          handleGoToDiskList: goToDiskList,
                          handleGoToNextPage: goToDiskList,
                          diskSelected: stateDiskSelected,
                        )))
              else if (statePageSelected == constPageHome)
                MaterialPage(
                    key: const ValueKey(constPageHome),
                    child: DefaultLayout(
                        handleSetLanguageCode: setLanguageCode,
                        languageSelected: stateLanguageSelected,
                        content: HomeView(
                          handleGoToDiskList: goToDiskList,
                        )))
            ])));
  }

  void setLanguageCode(String newValue) {
    LocalizationApi().setLanguageCode(newValue);
    setState(() {
      stateLanguageSelected = newValue;
    });
  }

  void goToDiskList() {
    setState(() {
      statePageSelected = constPageDiskList;
    });
  }

  void goToDiskSelected(String diskSelected) {
    setState(() {
      stateDiskSelected = diskSelected;
      statePageSelected = constPageDiskSelected;
    });
  }
}
