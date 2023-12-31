import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../engine/backgrounds/background_meta.dart';
import '../../engine/pieces/mahjong_tile.dart';
import '../../engine/tileset/tileset_flutter.dart';
import '../../engine/tileset/tileset_meta.dart';
import '../../preferences.dart';
import '../../screens/settings/background_screen.dart';
import '../../screens/settings/tileset_screen.dart';
import '../../widgets/tile.dart';

class SettingsPage extends StatefulWidget {
  static const Route = '/settings';
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

  static MaterialPageRoute generateRoute(RouteSettings routeSettings, Uri uri) {
    if (uri.pathSegments.length > 1 && uri.pathSegments[1] == 'tileset') {
      return MaterialPageRoute(builder: (context) => const SettingsTilesetPage());
    }
    if (uri.pathSegments.length > 1 && uri.pathSegments[1] == 'background') {
      return MaterialPageRoute(builder: (context) => SettingsBackgroundPage());
    }
    return MaterialPageRoute(builder: (context) => const SettingsPage());
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Consumer3<Preferences?, TilesetMetaCollection?,
            BackgroundMetaCollection?>(
          builder: (context,
              Preferences? preferences,
              TilesetMetaCollection? tilesets,
              BackgroundMetaCollection? backgrounds,
              child) {
            if (preferences == null) return const Text("");
            return ListView(
              children: <Widget>[
                ...tilesetListTiles(preferences, tilesets),
                ...backgroundListTiles(preferences, backgrounds),
                ListTile(
                  leading: const Text("Maximum retries: "),
                  title: retryButtons(preferences),
                ),
                CheckboxListTile(
                  title: const Text("Highlight moveable tiles: "),
                  value: preferences.highlightMovables,
                  onChanged: (val) {
                    preferences.highlightMovables = val ?? false;
                    setState(() {});
                  },
                ),
                ListTile(
                  title: const Text("About"),
                  onTap: () {
                    showAboutDialog(context: context, children: [
                      const Text(
                          "An ad-free, open-source Mahjong Solitaire implementation."),
                      TextButton(
                          onPressed: () =>
                              launch("https://github.com/edave64/ED-Mahjong"),
                          child: const Text("View source"))
                    ]);
                  },
                ),
              ],
            );
          },
        ));
  }

  Widget retryButtons(Preferences? preferences) {
    if (preferences == null) return const Text("");

    final count = preferences.maxShuffles;

    return Row(
      children: [
        TextButton(
            onPressed: count == -1
                ? null
                : () {
                    preferences.maxShuffles--;
                    setState(() {});
                  },
            child: const Icon(Icons.remove)),
        Text(count == -1 ? "Infinite" : "$count"),
        TextButton(
            onPressed: () {
              preferences.maxShuffles++;
              setState(() {});
            },
            child: const Icon(Icons.add)),
      ],
    );
  }

  Iterable<ListTile> tilesetListTiles(
      Preferences preferences, TilesetMetaCollection? tilesets) {
    final locale = PlatformDispatcher.instance.locale;
    if (tilesets == null) {
      return [ListTile(title: Text(preferences.tileset))];
    }
    final tileset = tilesets.get(preferences.tileset);
    final localString = tileset.name.toLocaleString(locale);
    return [
      ListTile(
        leading: previewTile(tileset),
        title: Text('Tileset: $localString'),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/settings/tileset',
          ).then((value) => setState(() {}));
        },
      ),
      ListTile(
        leading: const Text('Author:'),
        title: Text("${tileset.author} (${tileset.authorEmail})"),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Licence of '$localString' Tileset"),
                  content: FutureBuilder(
                      future: loadLicence(context, tileset),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Could not load licence data.");
                        }
                        if (!snapshot.hasData) {
                          return const Text("Loading licence data...");
                        }
                        return Text(snapshot.data as String);
                      }),
                  actions: <Widget>[
                    TextButton(
                        child: const Text('Neat!'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ],
                );
              });
        },
      ),
      if (tileset.description.toString() != "")
        ListTile(
          leading: const Text('Description:'),
          title: Text(tileset.description.toLocaleString(locale)),
        )
    ];
  }

  Iterable<ListTile> backgroundListTiles(
      Preferences preferences, BackgroundMetaCollection? backgrounds) {
    final locale = PlatformDispatcher.instance.locale;
    final backgroundName = preferences.background;

    onTap() {
      Navigator.pushNamed(
        context,
        '/settings/background',
      ).then((value) => setState(() {}));
    }

    if (backgroundName == null) {
      return [ListTile(title: const Text("Background: None"), onTap: onTap)];
    }
    if (backgrounds == null) {
      return [
        ListTile(title: Text("Background: $backgroundName"), onTap: onTap)
      ];
    }
    final background = backgrounds.get(backgroundName);
    return [
      ListTile(
        title: Text('Background: ${background.name.toLocaleString(locale)}'),
        onTap: onTap,
      ),
      ListTile(
        leading: const Text('Author:'),
        title: Text(
            "${background.author} ${background.authorEmail ?? ""}"),
      ),
    ];
  }

  retryCounterTile() {}
}

Widget previewTile(TilesetMeta tileset) {
  return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
          width: 50,
          height: 50,
          child: FittedBox(
              child: Tile(
                  type: MahjongTile.BAMBOO_1,
                  selected: false,
                  tilesetMeta: tileset))));
}
