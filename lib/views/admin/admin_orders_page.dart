import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_orders_detail_page.dart';
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final res = await supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng khách'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long,
                      color: Colors.deepOrange),
                  title: Text('Đơn #${o['id'].toString().substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng tiền: ${NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '₫',
                      ).format(o['total_amount'])}'),
                      Text('Trạng thái: ${o['status']}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminOrderDetailPage(order: o),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
