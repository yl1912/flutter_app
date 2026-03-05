import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminEditProductPage extends StatefulWidget {
  final Map product;
  const AdminEditProductPage({super.key, required this.product});

  @override
  State<AdminEditProductPage> createState() =>
      _AdminEditProductPageState();
}

class _AdminEditProductPageState extends State<AdminEditProductPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController categoryCtrl;
  late TextEditingController imageCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController descCtrl;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    nameCtrl = TextEditingController(text: p['name']);
    priceCtrl = TextEditingController(text: p['price'].toString());
    categoryCtrl = TextEditingController(text: p['category']);
    imageCtrl = TextEditingController(text: p['image_url']);
    stockCtrl = TextEditingController(text: p['stock'].toString());
    descCtrl =
        TextEditingController(text: p['description'] ?? ''); // ✅
  }

  Future<void> updateProduct() async {
    try {
      setState(() => loading = true);

      await supabase.from('products').update({
        'name': nameCtrl.text.trim(),
        'price': int.parse(priceCtrl.text),
        'category': categoryCtrl.text.trim(),
        'image_url': imageCtrl.text.trim(),
        'stock': int.parse(stockCtrl.text),
        'description': descCtrl.text.trim(),
      }).eq('id', widget.product['id']);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi khi cập nhật sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _input(
      TextEditingController c,
      String label, {
        bool number = false,
        int maxLine = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLine,
        keyboardType:
        number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa sản phẩm'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _input(nameCtrl, 'Tên sản phẩm'),
            _input(priceCtrl, 'Giá', number: true),
            _input(categoryCtrl, 'Danh mục'),
            _input(imageCtrl, 'Link ảnh'),
            _input(stockCtrl, 'Tồn kho', number: true),
            _input(
              descCtrl,
              'Mô tả sản phẩm',
              maxLine: 4,
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: loading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  'Cập nhật sản phẩm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
