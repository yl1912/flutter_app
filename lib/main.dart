import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'views/auth/login_page.dart';
import 'views/home/home_page.dart';

void main() {
  runApp(ShopeeApp());
}

class ShopeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping online MVVM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: AppRoutes.routes,
    );
  }
}
