import 'package:flutter/material.dart';
import '../views/auth/login_page.dart';
import '../views/home/home_page.dart';
import '../views/cart/cart_page.dart';
import '../views/profile/profile_page.dart';

class AppRoutes {
  static final routes = {
    '/login': (context) => LoginPage(),
    '/home': (context) => HomePage(),
    '/cart': (context) => CartPage(),
    '/profile': (context) => ProfilePage(),
  };
}
