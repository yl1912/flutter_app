import 'package:flutter/material.dart';
import 'package:project1/services/cart_service.dart';
import 'package:project1/utils/money_formatter.dart';
import 'package:project1/core/app_auth_state.dart';

class ProductDetailPage extends StatelessWidget {
  final Map product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final CartService cartService = CartService();

    /// ================== THÊM VÀO GIỎ ==================
    Future<void> addToCart() async {
      // ❌ CHƯA LOGIN → LOGIN
      if (!AppAuthState.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // ❌ ADMIN KHÔNG ĐƯỢC MUA
      if (AppAuthState.role == 'admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin không thể mua hàng'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ USER → THÊM GIỎ
      await cartService.addToCart(product['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm vào giỏ hàng'),
          backgroundColor: Colors.deepOrange,
        ),
      );
    }

    /// ================== MUA NGAY ==================
    void buyNow() {
      // ❌ CHƯA LOGIN → LOGIN
      if (!AppAuthState.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // ❌ ADMIN KHÔNG ĐƯỢC MUA
      if (AppAuthState.role == 'admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin không thể mua hàng'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ USER → CHECKOUT (MUA NGAY)
      Navigator.pushNamed(
        context,
        '/checkout',
        arguments: {
          'buy_now': true,
          'product': product,
          'quantity': 1,
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(product['name'] ?? 'Chi tiết sản phẩm'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🖼️ ẢNH SẢN PHẨM (DÀI)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product['image_url'] ?? '',
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 📦 TÊN
            Text(
              product['name'] ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            /// 💰 GIÁ
            Text(
              '${MoneyFormatter.format(product['price'] ?? 0)}đ',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 12),

            /// 📝 MÔ TẢ
            Text(
              product['description'] ?? 'Chưa có mô tả sản phẩm',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      /// ================== NÚT DƯỚI ==================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// 🛒 THÊM VÀO GIỎ
            Expanded(
              child: OutlinedButton.icon(
                onPressed: addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Thêm vào giỏ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  side: const BorderSide(color: Colors.deepOrange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// ⚡ MUA NGAY
            Expanded(
              child: ElevatedButton(
                onPressed: buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Mua ngay',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
