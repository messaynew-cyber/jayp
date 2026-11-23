import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'services/store.dart';
import 'services/api.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.instance.init();
  await Api.instance.init();
  await _seedCatalogue();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.ground,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const JayPApp());
}

/// Seeds the episode catalogue before the UI mounts, so no screen can ever
/// render against an empty table. Idempotent, and repairs a corrupt/empty
/// database on the second pass.
Future<void> _seedCatalogue() async {
  List<Map<String, dynamic>> rows = [];
  try {
    final raw = await rootBundle.loadString('assets/data/episodes.json');
    rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  } catch (_) {
    return; // asset missing entirely — nothing we can do here
  }
  if (rows.isEmpty) return;

  var inserted = await Store.instance.seedEpisodes(rows);
  var total = await Store.instance.episodeCount();

  // Second pass: table still empty despite a successful seed => repair.
  if (total == 0) {
    await Store.instance.reseedEpisodes(rows);
    total = await Store.instance.episodeCount();
  }
  debugPrint('JayP seed: $inserted inserted, $total in table');
}

class JayPApp extends StatelessWidget {
  const JayPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JayP',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
