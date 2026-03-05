import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  Future<String?> createOrder({
    required int totalAmount,
    required String status,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final res = await supabase
        .from('orders')
        .insert({
      'user_id': user.id,
      'total_amount': totalAmount,
      'status': status,
    })
        .select()
        .single();

    return res['id'];
  }

  Future<void> addOrderItem({
    required String orderId,
    required int productId,
    required int quantity,
    required int price,
  }) async {
    await supabase.from('order_items').insert({
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    });
  }
}
