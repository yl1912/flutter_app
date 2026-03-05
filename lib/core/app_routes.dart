import 'package:flutter/material.dart';

// Pages
import 'package:project1/views/home/home_page.dart';
import 'package:project1/views/auth/login_page.dart';
import 'package:project1/views/auth/register_page.dart';
import 'package:project1/views/auth/forgot_password_page.dart';

import 'package:project1/views/cart/cart_page.dart';
import 'package:project1/pages/checkout_page.dart';
import 'package:project1/views/profile/profile_page.dart';
import 'package:project1/views/profile/chat_page.dart';

import 'package:project1/views/admin/admin_dashboard_page.dart';
import 'package:project1/views/admin/admin_products_page.dart';
import 'package:project1/views/admin/admin_add_product_page.dart';
import 'package:project1/views/admin/admin_orders_page.dart';
import 'package:project1/views/admin/admin_orders_detail_page.dart';

import 'package:project1/views/orders/order_status_page.dart';

// Voucher
import 'package:project1/views/cart/voucher_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    // ===== USER =====
    '/home': (_) => const HomePage(),
    '/login': (_) => const LoginPage(),
    '/register': (_) => const RegisterPage(),
    '/forgot-password': (_) => const ForgotPasswordPage(),

    '/cart': (_) => const CartPage(),
    '/checkout': (_) => const CheckoutPage(),
    '/profile': (_) => const ProfilePage(),
    '/chat': (_) => const ChatPage(),

    // ===== ADMIN =====
    '/admin-dashboard': (_) => const AdminDashboardPage(),
    '/admin-products': (_) => const AdminProductsPage(),
    '/admin-add-product': (_) => const AdminAddProductPage(),
    '/admin-orders': (_) => const AdminOrdersPage(),

    // ✅ ADMIN – CHI TIẾT ĐƠN HÀNG (NHẬN ORDER MAP)
    '/admin-order-detail': (context) {
      final order =
      ModalRoute.of(context)!.settings.arguments
      as Map<String, dynamic>;
      return AdminOrderDetailPage(order: order);
    },

    // ===== ORDER STATUS (USER) =====
    '/order-status': (context) {
      final status =
      ModalRoute.of(context)!.settings.arguments as String;
      return OrderStatusPage(status: status);
    },

    // ===== VOUCHER =====
    '/voucher': (context) {
      final total =
      ModalRoute.of(context)!.settings.arguments as int;
      return VoucherPage(totalPrice: total);
    },
  };
}
