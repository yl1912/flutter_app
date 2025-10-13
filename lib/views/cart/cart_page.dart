import 'package:flutter/material.dart';
import 'package:project1/widgets/base_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Giỏ hàng mẫu
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Áo thun Shopee',
      'price': 99000,
      'quantity': 1,
      'image': 'https://via.placeholder.com/100x100.png?text=Ao+Shopee'
    },
    {
      'name': 'Tai nghe Bluetooth',
      'price': 199000,
      'quantity': 2,
      'image': 'https://via.placeholder.com/100x100.png?text=Tai+nghe'
    },
  ];

  // Tính tổng tiền
  int get totalPrice {
    return cartItems.fold(
        0,
            (sum, item) =>
        sum + (item['price'] as int) * (item['quantity'] as int));
  }

  void increaseQuantity(int index) {
    setState(() => cartItems[index]['quantity']++);
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) cartItems[index]['quantity']--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        backgroundColor: Colors.deepOrange,
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, i) {
                final item = cartItems[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Image.network(item['image'], width: 60),
                    title: Text(item['name']),
                    subtitle: Text(
                      '${item['price']}đ',
                      style: const TextStyle(color: Colors.deepOrange),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => decreaseQuantity(i),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${item['quantity']}'),
                        IconButton(
                          onPressed: () => increaseQuantity(i),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Tổng tiền
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng cộng:',
                        style: TextStyle(fontSize: 16)),
                    Text(
                      '${totalPrice.toString()}đ',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/checkout');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Thanh toán',
                      style:
                      TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
