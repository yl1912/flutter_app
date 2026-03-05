import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const AdminOrderDetailPage({
    super.key,
    required this.order,
  });

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = fetchItems();
  }

  // ================= INFO ROW =================
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FETCH ORDER ITEMS =================
  Future<List<Map<String, dynamic>>> fetchItems() async {
    final res = await supabase
        .from('order_items')
        .select('''
          quantity,
          price,
          products (
            name,
            image_url
          )
        ''')
        .eq('order_id', widget.order['id']);

    return List<Map<String, dynamic>>.from(res);
  }

  // ================= UPDATE STATUS =================
  Future<void> updateStatus(String status) async {
    await supabase
        .from('orders')
        .update({'status': status})
        .eq('id', widget.order['id']);

    setState(() {
      widget.order['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Đã cập nhật trạng thái: $status')),
    );
  }

  // ================= CANCEL ORDER =================
  Future<void> cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy đơn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await supabase
        .from('orders')
        .update({'status': 'Đã hủy'})
        .eq('id', widget.order['id']);

    setState(() {
      widget.order['status'] = 'Đã hủy';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Đơn hàng đã bị hủy'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn #${order['id'].substring(0, 8)}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          // ================= ORDER + CUSTOMER INFO =================
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin người đặt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  _infoRow('Họ tên:', order['full_name'] ?? 'Không có'),
                  _infoRow('SĐT:', order['phone'] ?? 'Không có'),
                  _infoRow('Địa chỉ:', order['address'] ?? 'Không có'),

                  const Text(
                    'Thông tin đơn hàng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  _infoRow('Mã đơn:', order['id'].substring(0, 8)),
                  _infoRow(
                    'Tổng tiền:',
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                        .format(order['total_amount']),
                  ),
                  _infoRow('Trạng thái:', order['status']),
                  _infoRow(
                    'Ngày đặt:',
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(DateTime.parse(order['created_at'])),
                  ),

                  const Divider(height: 24),


                ],
              ),
            ),
          ),

          // ================= ORDER ITEMS + CANCEL BANNER =================
          Expanded(
            child: Column(
              children: [
                // 🔴 THÔNG BÁO ĐƠN ĐÃ HỦY
                if (order['status'] == 'Đã hủy')
                  Container(
                    width: double.infinity,
                    margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Đơn hàng này đã bị hủy',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 📦 DANH SÁCH SẢN PHẨM (LUÔN HIỂN THỊ)
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _itemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Không có sản phẩm'));
                      }

                      final items = snapshot.data!;

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          final product = item['products'];

                          return ListTile(
                            leading: Image.network(
                              product['image_url'],
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image),
                            ),
                            title: Text(product['name']),
                            subtitle: Text(
                              'SL: ${item['quantity']} × ${NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                              ).format(item['price'])}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ================= ACTION BUTTONS =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (order['status'] == 'Đang chờ xác nhận') ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.inventory, color: Colors.white),
                    label: const Text('Đã gói hàng',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () => updateStatus('Đã gói hàng'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('Hủy đơn',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: cancelOrder,
                  ),
                ],

                if (order['status'] == 'Đã gói hàng')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.local_shipping,
                        color: Colors.white),
                    label: const Text(
                      'Bàn giao đơn vị vận chuyển',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () => updateStatus('Đang giao hàng'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
