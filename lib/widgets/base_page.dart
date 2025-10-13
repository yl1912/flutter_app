import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final VoidCallback? onSearch; // ✅ thêm callback khi bấm nút tìm kiếm

  const BasePage({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepOrange,
        leading: canGoBack
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : null,

        // ✅ thêm nút tìm kiếm bên phải
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Tìm kiếm',
            onPressed: onSearch ??
                    () {
                  // Hành động mặc định nếu không truyền onSearch
                  showSearchDialog(context);
                },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  // ✅ hàm hiển thị dialog tìm kiếm mặc định
  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController searchCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Tìm kiếm'),
          content: TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Nhập nội dung cần tìm...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final query = searchCtrl.text.trim();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang tìm: $query')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text('Tìm'),
            ),
          ],
        );
      },
    );
  }
}
