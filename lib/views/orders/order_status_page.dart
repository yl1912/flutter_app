import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_detail_page.dart';
import 'package:project1/utils/money_formatter.dart';


class OrderStatusPage extends StatefulWidget {
  final String status;
  const OrderStatusPage({super.key, required this.status});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .eq('status', widget.status)
        .order('created_at', ascending: false);

    setState(() {
      orders = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn ${widget.status}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text('Không có đơn nào'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final order = orders[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("Đơn #${order['id']}"),
              subtitle: Text(
                "Tổng: ${MoneyFormatter.format(order['total_amount'])}đ",
              ),

              trailing:
              const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailPage(
                      orderId: order['id'],
                    ),
                  ),
                );
                loadOrders(); // reload khi quay lại
              },
            ),
          );
        },
      ),
    );
  }
}
