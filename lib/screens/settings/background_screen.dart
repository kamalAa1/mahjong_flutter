import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../engine/backgrounds/background_meta.dart';
import '../../preferences.dart';

class SettingsBackgroundPage extends StatelessWidget {
  static const Route = '/settings/tilesets';
  SettingsBackgroundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Background'),
        ),
        body: Consumer2<Preferences?, BackgroundMetaCollection?>(builder:
            (context, Preferences? preferences,
                BackgroundMetaCollection? backgrounds, child) {
          final locale = PlatformDispatcher.instance.locale;
          if (preferences == null || backgrounds == null) return const Text("");
          return ListView(itemExtent: 50, children: [
            ListTile(
              title: const Text('None'),
              onTap: () {
                preferences.background = null;
                Navigator.of(context).pop();
              },
            ),
            ...backgrounds.list().map((background) => InkWell(
                child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/backgrounds/${background.fileName}"),
                          repeat: ImageRepeat.repeat,
                          fit: BoxFit.none),
                    ),
                    child: ListTile(
                      title: Stack(
                        children: <Widget>[
                          // Stroked text as border.
                          Text(
                            background.name.toLocaleString(locale),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.white,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            background.name.toLocaleString(locale),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        preferences.background = background.basename;
                        Navigator.of(context).pop();
                      },
                    ))))
          ]);
        }));
  }
}
