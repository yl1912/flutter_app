import 'package:supabase_flutter/supabase_flutter.dart';

class VoucherService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getVouchers() async {
    final today = DateTime.now().toIso8601String();

    final res = await supabase
        .from('vouchers')
        .select()
        .eq('is_active', true)
        .gte('expired_at', today)
        .order('discount_percent', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }
}
