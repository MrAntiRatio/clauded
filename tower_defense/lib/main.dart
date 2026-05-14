import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'services/persistence_service.dart';
import 'state/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await MobileAds.instance.initialize();
  await PersistenceService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        playerNotifierProvider.overrideWith(
          () => PlayerNotifier(PersistenceService.instance),
        ),
      ],
      child: const TowerDefenseApp(),
    ),
  );
}
