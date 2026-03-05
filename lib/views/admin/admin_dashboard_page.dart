import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị bán hàng'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(
            context,
            icon: Icons.inventory,
            title: 'Quản lý sản phẩm',
            route: '/admin-products',
          ),
          _item(
            context,
            icon: Icons.receipt_long,
            title: 'Đơn hàng khách',
            route: '/admin-orders',
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context,
      {required IconData icon,
        required String title,
        required String route}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
