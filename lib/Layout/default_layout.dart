import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:nix_disk_manager/Api/localization_api.dart';

class DefaultLayout extends StatefulWidget {
  final Widget content;
  final Function handleSetLanguageCode;
  final String languageSelected;

  const DefaultLayout({
    super.key,
    required this.content,
    required this.handleSetLanguageCode,
    required this.languageSelected,
  });

  @override
  DefaultLayoutState createState() => DefaultLayoutState();
}

class DefaultLayoutState extends State<DefaultLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
              ? IconButton(
                  onPressed: () => AdaptiveTheme.of(context).setLight(),
                  icon: Icon(Icons.light_mode))
              : IconButton(
                  onPressed: () => AdaptiveTheme.of(context).setDark(),
                  icon: Icon(Icons.dark_mode)),
          SizedBox(width: 10),
          DropdownButton<String>(
            icon: const Icon(Icons.language),
            value: widget.languageSelected,
            items: LocalizationApi.languages()
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(LocalizationApi().tr("language_$e")),
                    ))
                .toList(),
            onChanged: (String? newValue) async {
              if (newValue != null) {
                widget.handleSetLanguageCode(newValue);
              }
            },
          ),
          SizedBox(width: 10),
        ]),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(5),
          child: Card(
              elevation: 4,
              child: Scrollbar(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: widget.content))),
        )),
      ]),
    );
  }
}
