import 'package:flutter/material.dart';
import 'package:project1/services/cart_service.dart';
import 'package:project1/utils/money_formatter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService cartService = CartService();

  List<Map<String, dynamic>> cartItems = [];
  List<bool> selected = [];
  bool loading = true;

  /// 🎟️ VOUCHER
  Map<String, dynamic>? selectedVoucher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCart();
    });
  }

  /// ================================
  /// 🔹 LOAD GIỎ HÀNG
  /// ================================
  Future<void> loadCart() async {
    try {
      final data = await cartService.getCart();
      setState(() {
        cartItems = data;
        selected = List<bool>.filled(cartItems.length, false);
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Load cart error: $e');
      setState(() => loading = false);
    }
  }

  /// ================================
  /// 🔹 TỔNG TIỀN SP ĐƯỢC CHỌN
  /// ================================
  int get totalPrice {
    int sum = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (!selected[i]) continue;
      final p = cartItems[i]['products'];
      sum += (p['price'] as int) * (cartItems[i]['quantity'] as int);
    }
    return sum;
  }

  /// ================================
  /// 🎟️ GIẢM GIÁ VOUCHER (%)
  /// ================================
  int get discount {
    if (selectedVoucher == null) return 0;
    final int percent =
    (selectedVoucher!['discount_percent'] ?? 0) as int;
    return totalPrice * percent ~/ 100;
  }

  Future<void> updateQty(int index, int qty) async {
    if (qty < 1) return;
    await cartService.updateQuantity(cartItems[index]['id'], qty);
    await loadCart();
  }

  Future<void> removeItem(int index) async {
    await cartService.removeItem(cartItems[index]['id']);
    await loadCart();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Giỏ hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
                  (route) => false,
            );
          },
        ),
      ),

      body: cartItems.isEmpty
          ? const Center(child: Text('🛒 Giỏ hàng trống'))
          : Column(
        children: [
          /// ================================
          /// 🔹 DANH SÁCH SP
          /// ================================
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, i) {
                final item = cartItems[i];
                final p = item['products'];

                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selected[i],
                          activeColor: Colors.deepOrange,
                          onChanged: (v) {
                            setState(() => selected[i] = v ?? false);
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p['image_url'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${MoneyFormatter.format(p['price'])}đ',
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => updateQty(
                                      i,
                                      item['quantity'] - 1,
                                    ),
                                  ),
                                  Text('${item['quantity']}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => updateQty(
                                      i,
                                      item['quantity'] + 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItem(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// ================================
          /// 🎟️ VOUCHER
          /// ================================
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepOrange),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer,
                    color: Colors.deepOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedVoucher == null
                        ? 'Chưa chọn voucher'
                        : selectedVoucher!['code'],
                    style: TextStyle(
                      color: selectedVoucher == null
                          ? Colors.grey
                          : Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final v = await Navigator.pushNamed(
                      context,
                      '/voucher',
                      arguments: totalPrice,
                    );

                    setState(() {
                      if (v == null) {
                        selectedVoucher = null; //  KHÔNG CHỌN → KHÔNG ÁP
                      } else {
                        selectedVoucher = v as Map<String, dynamic>;
                      }
                    });
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text(
                    'Chọn',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ================================
          /// 💰 TỔNG + THANH TOÁN
          /// ================================
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: [
                _priceRow('Tạm tính', totalPrice),
                if (discount > 0)
                  _priceRow('Giảm voucher', -discount,
                      color: Colors.green),
                const Divider(),
                _priceRow(
                  'Tổng thanh toán',
                  totalPrice - discount,
                  bold: true,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 16),

                /// 🔥 NÚT THANH TOÁN
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: selected.every((e) => !e)
                        ? null
                        : () {
                      final List<Map<String, dynamic>> items = [];
                      for (int i = 0; i < cartItems.length; i++) {
                        if (selected[i]) {
                          items.add({
                            'cart_id': cartItems[i]['id'],
                            'quantity':
                            cartItems[i]['quantity'],
                            'product':
                            cartItems[i]['products'],
                          });
                        }
                      }

                      Navigator.pushNamed(
                        context,
                        '/checkout',
                        arguments: items,
                      );
                    },
                    child: const Text(
                      'Thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================================
  /// 🔹 PRICE ROW
  /// ================================
  Widget _priceRow(String label, int value,
      {bool bold = false, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${MoneyFormatter.format(value.abs())}đ',
            style: TextStyle(
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
