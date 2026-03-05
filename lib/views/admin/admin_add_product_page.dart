import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AdminAddProductPage({super.key, this.product});

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final supabase = Supabase.instance.client;

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String selectedCategory = 'Điện thoại';
  bool loading = false;

  final List<String> categories = [
    'Điện thoại',
    'Thời trang',
    'Mỹ phẩm',
    'Gia dụng',
    'Phụ kiện',
    'Giày dép',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      nameCtrl.text = p['name'];
      priceCtrl.text = p['price'].toString();
      imageCtrl.text = p['image_url'];
      stockCtrl.text = p['stock'].toString();
      descCtrl.text = p['description'] ?? '';
      selectedCategory = p['category'];
    }
  }

  Future<void> saveProduct() async {
    if (nameCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        imageCtrl.text.isEmpty ||
        stockCtrl.text.isEmpty) {
      _snack('⚠ Nhập đầy đủ thông tin');
      return;
    }

    final price = int.tryParse(priceCtrl.text);
    final stock = int.tryParse(stockCtrl.text);
    if (price == null || stock == null) {
      _snack('⚠ Giá & tồn kho phải là số');
      return;
    }

    setState(() => loading = true);

    final data = {
      'name': nameCtrl.text.trim(),
      'price': price,
      'category': selectedCategory,
      'image_url': imageCtrl.text.trim(),
      'stock': stock,
      'description': descCtrl.text.trim(),
    };

    try {
      if (widget.product == null) {
        await supabase.from('products').insert(data);
      } else {
        await supabase
            .from('products')
            .update(data)
            .eq('id', widget.product!['id']);
      }
      Navigator.pop(context);
    } catch (e) {
      _snack('❌ Lỗi lưu sản phẩm');
    } finally {
      setState(() => loading = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _input(TextEditingController ctrl, String label,
      {bool number = false, int maxLine = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: maxLine,
        keyboardType: number ? TextInputType.number : TextInputType.text,
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
        title: Text(widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _input(nameCtrl, 'Tên sản phẩm'),
            _input(priceCtrl, 'Giá', number: true),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((c) =>
                  DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v!),
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            _input(imageCtrl, 'Link ảnh'),
            _input(stockCtrl, 'Tồn kho', number: true),
            _input(descCtrl, 'Mô tả sản phẩm', maxLine: 4),

            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Lưu sản phẩm',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
