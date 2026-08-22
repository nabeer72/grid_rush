import 'package:get/get.dart';
import '../features/home/home_screen.dart';
import '../features/chapters/chapters_screen.dart';
import '../features/levels/level_select_screen.dart';
import '../features/gameplay/gameplay_screen.dart';
import '../features/results/results_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String chapters = '/chapters';
  static const String levelSelect = '/level_select';
  static const String gameplay = '/gameplay';
  static const String results = '/results';
  static const String settings = '/settings';

  static final routes = [
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: chapters, page: () => const ChaptersScreen()),
    GetPage(name: levelSelect, page: () => const LevelSelectScreen()),
    GetPage(name: gameplay, page: () => const GameplayScreen()),
    GetPage(name: results, page: () => const ResultsScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
  ];
}
