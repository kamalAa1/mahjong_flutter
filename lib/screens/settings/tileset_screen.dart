import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../engine/tileset/tileset_meta.dart';
import '../../preferences.dart';
import '../../screens/settings/settings_screen.dart';

class SettingsTilesetPage extends StatelessWidget {
  static const Route = '/settings/tilesets';
  const SettingsTilesetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tileset'),
      ),
      body: Consumer2<Preferences?, TilesetMetaCollection?>(builder: (context,
          Preferences? preferences, TilesetMetaCollection? tilesets, child) {
        final locale = PlatformDispatcher.instance.locale;
        if (preferences == null || tilesets == null) return const Text("");
        return LayoutBuilder(builder: (context, size) {
          return ListView(
              itemExtent: 50,
              children: tilesets
                  .list()
                  .map((tileset) => ListTile(
                        leading: previewTile(tileset),
                        title: Text(tileset.name.toLocaleString(locale)),
                        onTap: () {
                          preferences.tileset = tileset.basename;
                          Navigator.of(context).pop();
                        },
                      ))
                  .toList());
        });
      }),
    );
  }
}
