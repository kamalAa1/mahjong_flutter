import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/backgrounds/background_flutter.dart';
import '../engine/backgrounds/background_meta.dart';
import '../engine/layouts/layout_meta.dart';
import '../engine/tileset/tileset_flutter.dart';
import '../engine/tileset/tileset_meta.dart';
import '../preferences.dart';
import 'screens/game/game_screen.dart';
import 'screens/home.dart';
import 'screens/settings/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          FutureProvider<LayoutMetaCollection?>(
              create: (context) => LayoutMetaCollection.load(context),
              initialData: null),
          FutureProvider<TilesetMetaCollection?>(
              create: (context) => loadTilesets(context), initialData: null),
          FutureProvider<BackgroundMetaCollection?>(
              create: (context) => loadBackgrounds(context), initialData: null),
          FutureProvider(
              create: (context) => Preferences.instance, initialData: null),
        ],
        child: MaterialApp(
          title: 'ED Mahjong',
          theme: ThemeData(
            primarySwatch: Colors.amber,
            hintColor: Colors.amber,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.amber,
            hintColor: Colors.amber,
            brightness: Brightness.dark,
            /* dark theme settings */
          ),
          themeMode: ThemeMode.system,
          onGenerateRoute: (routeSettings) {
            final name = routeSettings.name;
            if (name == null || name == '/') {
              return MaterialPageRoute(
                  builder: (context) => const MyHomePage());
            }

            var uri = Uri.parse(name);
            if (uri.pathSegments.first == 'game') {
              return GamePage.generateRoute(routeSettings, uri);
            }

            if (uri.pathSegments.first == 'settings') {
              return SettingsPage.generateRoute(routeSettings, uri);
            }

            return MaterialPageRoute(builder: (context) => const MyHomePage());
          },
        ));
  }
}
