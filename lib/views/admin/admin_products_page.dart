import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_add_product_page.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final supabase = Supabase.instance.client;
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final res = await supabase.from('products').select().order('id');
    setState(() {
      products = res;
      loading = false;
    });
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('products').delete().eq('id', id);
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        backgroundColor: Colors.deepOrange,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminAddProductPage(),
            ),
          ).then((_) => loadProducts());
        },
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Image.network(
                p['image_url'],
                width: 50,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.image),
              ),
              title: Text(p['name']),
              subtitle: Text('${p['price']}đ | ${p['category']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✏️ SỬA
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminAddProductPage(product: p),
                        ),
                      ).then((_) => loadProducts());
                    },
                  ),

                  // 🗑️ XÓA
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteProduct(p['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
