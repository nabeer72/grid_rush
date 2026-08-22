import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart';
import 'theme.dart';

class GridRushApp extends StatelessWidget {
  const GridRushApp({super.key});

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
