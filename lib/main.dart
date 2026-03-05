import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:project1/core/app_routes.dart';
import 'package:project1/core/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zpksljuwhmhnmobxumcl.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpwa3NsanV3aG1obm1vYnh1bWNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NDQ1OTMsImV4cCI6MjA4MDEyMDU5M30.TPXCd3aQkab8CRvO6skH-s-qHldqeZMgz2tXVOm9Lsc',
  );

  runApp(const ShopMallApp());
}

class ShopMallApp extends StatelessWidget {
  const ShopMallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopMall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      routes: AppRoutes.routes,
    );
  }
}
