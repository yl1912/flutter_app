import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static final List<Map<String, String>> faqs = [
    {
      'q': 'Làm sao để đặt hàng?',
      'a': 'Bạn chọn sản phẩm → thêm vào giỏ → thanh toán.'
    },
    {
      'q': 'Làm sao áp dụng voucher?',
      'a': 'Vào giỏ hàng → chọn voucher → hệ thống tự giảm.'
    },
    {
      'q': 'Bao lâu thì nhận được hàng?',
      'a': 'Thời gian giao hàng từ 2–5 ngày làm việc.'
    },
    {
      'q': 'Tôi có thể huỷ đơn không?',
      'a': 'Bạn có thể huỷ khi đơn chưa được xác nhận.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung tâm trợ giúp'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Câu hỏi thường gặp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...faqs.map(
                (f) => ExpansionTile(
              title: Text(
                f['q']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    f['a']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                )
              ],
            ),
          ),

          const Divider(height: 40),

          const Text(
            'Bạn cần hỗ trợ thêm?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          /// 🔥 NÚT CHAT SHOPMALL (CHỮ TRẮNG)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.chat,
                color: Colors.white,
              ),
              label: const Text(
                'Trò chuyện với ShopMall',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
          ),
        ],
      ),
    );
  }
}
