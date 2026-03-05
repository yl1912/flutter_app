import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project1/utils/money_formatter.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? order;
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOrder();
  }

  // ===============================
  // 🔹 LOAD ORDER + ORDER ITEMS
  // ===============================
  Future<void> loadOrder() async {
    final o = await supabase
        .from('orders')
        .select()
        .eq('id', widget.orderId)
        .single();

    final i = await supabase
        .from('order_items')
        .select('''
          quantity,
          price,
          products (
            id,
            name,
            image_url
          )
        ''')
        .eq('order_id', widget.orderId);

    setState(() {
      order = o;
      items = List<Map<String, dynamic>>.from(i);
      loading = false;
    });
  }

  // ===============================
  // ❌ HỦY ĐƠN (GIỮ LOGIC)
  // ===============================
  Future<void> cancelOrder() async {
    await supabase
        .from('orders')
        .update({'status': 'Đã hủy'})
        .eq('id', widget.orderId);

    if (!mounted) return;

    setState(() {
      order!['status'] = 'Đã hủy';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ Đơn hàng đã được hủy"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ===============================
  // ❓ XÁC NHẬN HỦY ĐƠN
  // ===============================
  Future<void> confirmCancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận hủy đơn"),
        content: const Text(
          "Bạn có chắc chắn muốn hủy đơn hàng này không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Không"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hủy đơn",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await cancelOrder();
    }
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
        title: Text("Đơn #${order!['id']}"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔸 TRẠNG THÁI
            Text(
              "🟠 Trạng thái: ${order!['status']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),

            /// 🔹 THÔNG TIN NGƯỜI ĐẶT
            const Text(
              "Thông tin giao hàng:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("👤 Người nhận: ${order!['full_name']}"),
            Text("📞 Số điện thoại: ${order!['phone']}"),
            Text("📍 Địa chỉ: ${order!['address']}"),
            if (order!['note'] != null &&
                order!['note'].toString().isNotEmpty)
              Text("📝 Ghi chú: ${order!['note']}"),
            const Divider(),

            /// 🔸 DANH SÁCH SẢN PHẨM
            const Text(
              "Danh sách sản phẩm:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("Không có sản phẩm"))
                  : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final product = item['products'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          product['image_url'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(product['name']),
                      subtitle: Text(
                        "SL: ${item['quantity']} x ${MoneyFormatter.format(item['price'])}đ",
                      ),
                      trailing: Text(
                        "${MoneyFormatter.format(item['quantity'] * item['price'])}đ",
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// 🔸 TỔNG TIỀN
            Text(
              "💰 Tổng thanh toán: ${MoneyFormatter.format(order!['total_amount'])}đ",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      /// ❌ NÚT HỦY ĐƠN (CÓ XÁC NHẬN)
      bottomNavigationBar: order!['status'] == 'Đang chờ xác nhận'
          ? Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: confirmCancelOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            "Hủy đơn hàng",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      )
          : null,
    );
  }
}
