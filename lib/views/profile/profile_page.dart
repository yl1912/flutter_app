import 'package:flutter/material.dart';
import '../../widgets/base_page.dart';
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tài khoản của tôi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.deepOrange),
            SizedBox(height: 16),
            Text('Xin chào, người dùng!', style: TextStyle(fontSize: 20)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
