import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme.dart';
import 'controllers/home_controller.dart';
import 'tabs/home_tab.dart';
import 'tabs/events_tab.dart';
import 'tabs/shop_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final HomeController controller = Get.put(HomeController());
    
    // List of tabs corresponding to bottom nav index
    final List<Widget> tabs = [
      const HomeTab(),
      const EventsTab(),
      const ShopTab(),
      const ProfileTab(),
    ];

    return Obx(() => Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: tabs[controller.currentIndex.value],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.background,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'EVENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'SHOP'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    ));
  }
}
