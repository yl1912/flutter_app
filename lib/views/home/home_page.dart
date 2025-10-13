import 'package:flutter/material.dart';
import 'package:project1/widgets/base_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Điện thoại', 'icon': '📱'},
    {'name': 'Thời trang', 'icon': '👕'},
    {'name': 'Mỹ phẩm', 'icon': '💄'},
    {'name': 'Gia dụng', 'icon': '🏠'},
  ];

  final List<Map<String, String>> products = [
    {'name': 'Áo thun Shopee', 'price': '99.000đ', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Tai nghe Bluetooth', 'price': '199.000đ', 'image': 'https://via.placeholder.com/150'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Online')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Danh mục
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CircleAvatar(child: Text(categories[i]['icon']!, style: TextStyle(fontSize: 24))),
                      Text(categories[i]['name']!),
                    ],
                  ),
                ),
              ),
            ),

            // Sản phẩm nổi bật
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (_, i) {
                final p = products[i];
                return GestureDetector(
                  onTap: () {},
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Image.network(p['image']!, height: 120, fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(p['name']!, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        Text(p['price']!, style: TextStyle(color: Colors.deepOrange)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepOrange,
        onTap: (i) {
          switch (i) {
            case 0: Navigator.pushReplacementNamed(context, '/home'); break;
            case 1: Navigator.pushReplacementNamed(context, '/cart'); break;
            case 2: Navigator.pushReplacementNamed(context, '/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
