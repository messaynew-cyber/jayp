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
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.ground,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const JayPApp());
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
