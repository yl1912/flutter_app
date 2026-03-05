import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  /// 🛒 ITEMS
  List<Map<String, dynamic>> items = [];

  /// 🎟️ VOUCHER
  Map<String, dynamic>? selectedVoucher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null) return;

    /// ===== MUA NGAY =====
    if (args is Map && args['buy_now'] == true) {
      items = [
        {
          'product': args['product'],
          'quantity': args['quantity'] ?? 1,
        }
      ];
    }

    /// ===== TỪ GIỎ HÀNG =====
    else if (args is List) {
      items = List<Map<String, dynamic>>.from(args);
    }
  }

  /// ================= MONEY =================
  String formatMoney(int amount) {
    return NumberFormat('#,###', 'vi_VN')
        .format(amount)
        .replaceAll(',', '.');
  }

  int get totalPrice {
    int sum = 0;
    for (final item in items) {
      final p = item['product'];
      sum += (p['price'] as int) * (item['quantity'] as int);
    }
    return sum;
  }

  int get shippingFee => totalPrice >= 500000 ? 0 : 30000;

  int get discount {
    if (selectedVoucher == null) return 0;
    return totalPrice *
        (selectedVoucher!['discount_percent'] as int) ~/
        100;
  }

  int get grandTotal => totalPrice + shippingFee - discount;

  /// ================= SUBMIT =================
  Future<void> _submitOrder() async {
    try {
      /// 0️⃣ VALIDATE
      if (nameCtrl.text.trim().isEmpty ||
          phoneCtrl.text.trim().isEmpty ||
          addressCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập đầy đủ thông tin giao hàng'),
          ),
        );
        return;
      }

      final user = supabase.auth.currentUser;
      if (user == null || items.isEmpty) return;

      /// 1️⃣ TẠO ORDER
      final orderRes = await supabase
          .from('orders')
          .insert({
        'user_id': user.id,
        'full_name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'total_amount': grandTotal,
        'status': 'Đang chờ xác nhận',
      })
          .select()
          .single();

      final String orderId = orderRes['id'];

      /// 2️⃣ ORDER ITEMS
      final orderItems = items.map((item) {
        final p = item['product'];
        return {
          'order_id': orderId,
          'product_id': p['id'],
          'quantity': item['quantity'],
          'price': p['price'],
        };
      }).toList();

      await supabase.from('order_items').insert(orderItems);

      /// 3️⃣ LƯU VOUCHER (FIX CHUẨN)
      if (selectedVoucher != null && selectedVoucher!['id'] != null) {
        await supabase.from('user_vouchers').insert({
          'user_id': user.id,
          'voucher_id': selectedVoucher!['id'],
          'order_id': orderId,
          'used_at': DateTime.now().toIso8601String(),
        });
      }

      /// 4️⃣ XOÁ CART (GIỮ LOGIC CŨ)
      for (final item in items) {
        await supabase
            .from('cart')
            .delete()
            .eq('user_id', user.id)
            .eq('product_id', item['product']['id']);
      }

      if (!mounted) return;

      /// 5️⃣ THÔNG BÁO
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 Đặt hàng thành công'),
          content: const Text('Đơn hàng đã được ghi nhận'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ submitOrder error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đặt hàng: $e')),
      );
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.deepOrange,
      ),
      body: items.isEmpty
          ? const Center(child: Text('🛍️ Giỏ hàng trống'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section(
              title: 'Thông tin giao hàng',
              child: Column(
                children: [
                  _input(nameCtrl, 'Họ và tên'),
                  _input(phoneCtrl, 'Số điện thoại'),
                  _input(addressCtrl, 'Địa chỉ', maxLines: 2),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ...items.map((item) {
              final p = item['product'];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    p['image_url'],
                    width: 50,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image),
                  ),
                  title: Text(p['name']),
                  subtitle: Text(
                    'SL ${item['quantity']} x ${formatMoney(p['price'])}đ',
                  ),
                  trailing: Text(
                    '${formatMoney(p['price'] * item['quantity'])}đ',
                    style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            /// VOUCHER
            Container(
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
                        selectedVoucher =
                        v == null ? null : v as Map<String, dynamic>;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange),
                    child: const Text('Chọn',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _rowMoney('Tiền hàng', totalPrice),
            _rowMoney('Phí ship', shippingFee),
            if (discount > 0)
              _rowMoney('Giảm voucher', -discount,
                  highlight: true),
            const Divider(),
            _rowMoney('Tổng thanh toán', grandTotal,
                bold: true, highlight: true),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Xác nhận đặt hàng',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= HELPERS =================
  Widget _rowMoney(String label, int value,
      {bool bold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(
          '${formatMoney(value.abs())}đ',
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.deepOrange : Colors.black),
        ),
      ],
    );
  }

  Widget _input(TextEditingController c, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
