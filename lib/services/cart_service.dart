import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final SupabaseClient supabase = Supabase.instance.client;

  // =================================================
  // 🛒 LẤY GIỎ HÀNG CỦA USER (ĐÃ FIX LỖI FK)
  // =================================================
  Future<List<Map<String, dynamic>>> getCart() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('❌ USER NULL');
      return [];
    }

    try {
      final data = await supabase
          .from('cart')
          .select('''
            id,
            quantity,
            products!cart_product_id_fkey (
              id,
              name,
              price,
              image_url
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      debugPrint('🛒 CART DATA: $data');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ getCart error: $e');
      return [];
    }
  }

  // =================================================
  // 🔢 LẤY TỔNG SỐ LƯỢNG SP (BADGE)
  // =================================================
  Future<int> getCartCount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 0;

    try {
      final data = await supabase
          .from('cart')
          .select('quantity')
          .eq('user_id', user.id);

      int total = 0;
      for (final item in data) {
        total += (item['quantity'] as int);
      }

      debugPrint('🛒 CART COUNT: $total');
      return total;
    } catch (e) {
      debugPrint('❌ getCartCount error: $e');
      return 0;
    }
  }

  // =================================================
  // ➕ THÊM SẢN PHẨM VÀO GIỎ
  // =================================================
  Future<void> addToCart(int productId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final existing = await supabase
          .from('cart')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        await supabase
            .from('cart')
            .update({
          'quantity': (existing['quantity'] as int) + 1,
        })
            .eq('id', existing['id']);
      } else {
        await supabase.from('cart').insert({
          'user_id': user.id,
          'product_id': productId,
          'quantity': 1,
        });
      }

      debugPrint('✅ ADD TO CART OK: productId=$productId');
    } catch (e) {
      debugPrint('❌ addToCart error: $e');
    }
  }

  // =================================================
  // 🔄 CẬP NHẬT SỐ LƯỢNG
  // =================================================
  Future<void> updateQuantity(String cartId, int quantity) async {
    if (quantity < 1) return;

    try {
      await supabase
          .from('cart')
          .update({'quantity': quantity})
          .eq('id', cartId);
    } catch (e) {
      debugPrint('❌ updateQuantity error: $e');
    }
  }

  // =================================================
  // 🗑️ XÓA 1 SẢN PHẨM
  // =================================================
  Future<void> removeItem(String cartId) async {
    try {
      await supabase.from('cart').delete().eq('id', cartId);
    } catch (e) {
      debugPrint('❌ removeItem error: $e');
    }
  }

  // =================================================
  // 🧹 XÓA TOÀN BỘ GIỎ HÀNG
  // =================================================
  Future<void> clearCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('cart').delete().eq('user_id', user.id);
    } catch (e) {
      debugPrint('❌ clearCart error: $e');
    }
  }
}
