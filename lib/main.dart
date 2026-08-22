import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'data/coin_repository.dart';
import 'data/progress_repository.dart';
import 'features/settings/controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressRepository.ensureInitialized();
  final coinRepo = Get.put(CoinRepository(), permanent: true);
  await coinRepo.ensureInitialized();
  final settings = Get.put(SettingsController(), permanent: true);
  await settings.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Grid Rush',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
