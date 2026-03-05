import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project1/utils/money_formatter.dart';

class VoucherPage extends StatefulWidget {
  final int totalPrice;
  const VoucherPage({super.key, required this.totalPrice});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;

  /// danh sách gốc
  List<Map<String, dynamic>> vouchers = [];

  /// danh sách sau khi tìm kiếm
  List<Map<String, dynamic>> filteredVouchers = [];

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVouchers();
    searchCtrl.addListener(_filterVoucher);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    try {
      final today =
      DateTime.now().toIso8601String().substring(0, 10);

      final data = await supabase
          .from('vouchers')
          .select()
          .eq('is_active', true)
          .gte('expired_at', today)
          .lte('min_order', widget.totalPrice)
          .order('discount_percent', ascending: false);

      vouchers = List<Map<String, dynamic>>.from(data);
      filteredVouchers = vouchers;

      setState(() => loading = false);
    } catch (e) {
      debugPrint('❌ LOAD VOUCHER ERROR: $e');
      setState(() => loading = false);
    }
  }

  /// 🔍 lọc voucher theo code
  void _filterVoucher() {
    final keyword = searchCtrl.text.trim().toLowerCase();

    setState(() {
      if (keyword.isEmpty) {
        filteredVouchers = vouchers;
      } else {
        filteredVouchers = vouchers.where((v) {
          final code = (v['code'] ?? '').toString().toLowerCase();
          return code.contains(keyword);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn voucher'),
        backgroundColor: Colors.deepOrange,
      ),

      /// 👇 KHÔNG CHỌN VOUCHER
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: OutlinedButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepOrange),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Không chọn voucher',
            style: TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// 🔍 Ô tìm kiếm voucher
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: 'Nhập mã voucher...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// 📋 Danh sách voucher
          Expanded(
            child: filteredVouchers.isEmpty
                ? const Center(
              child: Text('Không có voucher phù hợp'),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.only(bottom: 80),
              itemCount: filteredVouchers.length,
              itemBuilder: (_, i) {
                final v = filteredVouchers[i];

                final String code =
                    v['code']?.toString() ?? '---';
                final int discount =
                (v['discount_percent'] ?? 0)
                as int;
                final int minOrder =
                (v['min_order'] ?? 0) as int;
                final String expired =
                    v['expired_at']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_offer,
                      color: Colors.deepOrange,
                      size: 30,
                    ),
                    title: Text(
                      code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Giảm $discount%'),
                        Text(
                          'Đơn tối thiểu ${MoneyFormatter.format(minOrder)}đ',
                        ),
                        if (expired.isNotEmpty)
                          Text(
                            'HSD: $expired',
                            style: const TextStyle(
                                color: Colors.grey),
                          ),
                      ],
                    ),

                    /// ✅ FIX TẠI ĐÂY
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'id': v['id'], // ⭐ BẮT BUỘC
                          'code': v['code'],
                          'discount_percent':
                          v['discount_percent'],
                        });
                      },
                      child: const Text(
                        'Dùng',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
