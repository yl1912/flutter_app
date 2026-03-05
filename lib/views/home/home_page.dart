import 'package:flutter/material.dart';
import 'package:project1/core/app_auth_state.dart';
import 'package:project1/services/cart_service.dart';
import 'package:project1/pages/product_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project1/utils/money_formatter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final CartService cartService = CartService();

  final List<Map<String, String>> categories = [
    {'name': 'Tất cả', 'icon': '🛒'},
    {'name': 'Điện thoại', 'icon': '📱'},
    {'name': 'Thời trang', 'icon': '👕'},
    {'name': 'Mỹ phẩm', 'icon': '💄'},
    {'name': 'Gia dụng', 'icon': '🏠'},
    {'name': 'Phụ kiện', 'icon': '🎧'},
    {'name': 'Giày dép', 'icon': '👟'},
  ];

  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  bool isSearching = false;

  String selectedCategory = 'Tất cả';
  final TextEditingController searchCtrl = TextEditingController();

  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCartCount();
  }

  /// ================================
  /// 🔹 LOAD SẢN PHẨM
  /// ================================
  Future<void> _loadProducts() async {
    final response =
    await supabase.from('products').select().order('created_at');

    setState(() {
      allProducts = response;
      filteredProducts = response;
    });
  }

  /// ================================
  /// 🔹 LOAD BADGE GIỎ HÀNG
  /// ================================
  Future<void> _loadCartCount() async {
    if (!AppAuthState.isLoggedIn) {
      setState(() => cartCount = 0);
      return;
    }

    final count = await cartService.getCartCount();
    setState(() => cartCount = count);
  }

  void _searchProduct(String keyword) {
    setState(() {
      isSearching = keyword.isNotEmpty;

      filteredProducts = allProducts.where((p) {
        final name = p['name'].toString().toLowerCase();
        return name.contains(keyword.toLowerCase());
      }).toList();
    });
  }


  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      filteredProducts = allProducts.where((p) {
        return category == 'Tất cả' || p['category'] == category;
      }).toList();
    });
  }

  /// ================================
  /// ✅ THÊM VÀO GIỎ
  /// ================================
  Future<void> _addToCart(Map p) async {
    if (!AppAuthState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm giỏ hàng'),
          backgroundColor: Colors.red,
        ),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    await cartService.addToCart(p['id'] as int);
    await _loadCartCount();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p['name']} đã thêm vào giỏ hàng!'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'ShopMall',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchCtrl,
                onChanged: _searchProduct,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon:
                  const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // ✅ ADMIN: chỉ hiện nút quản lý
          if (AppAuthState.role == 'admin')
            IconButton(
              icon: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pushNamed(context, '/admin-dashboard'),
            ),

          // ✅ USER: mới hiện giỏ hàng
          if (AppAuthState.role != 'admin')
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (!AppAuthState.isLoggedIn) {
                      Navigator.pushReplacementNamed(context, '/login');
                      return;
                    }
                    Navigator.pushReplacementNamed(context, '/cart');
                  },
                ),

                if (cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],

      ),

      body: filteredProducts.isEmpty
          ? Center(
        child: isSearching
            ? const Text(
          '❌ Không tìm thấy sản phẩm',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        )
            : const CircularProgressIndicator(),
      )
          : _buildProductGrid(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            AppAuthState.isLoggedIn
                ? Navigator.pushReplacementNamed(context, '/profile')
                : Navigator.pushReplacementNamed(context, '/login');
          }
        },
      ),
    );
  }

  /// ================================
  /// 🔹 MENU CATEGORY + GRID SẢN PHẨM
  /// ================================
  Widget _buildProductGrid() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 6),

          /// 🔹 CATEGORY
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final c = categories[i];
                final bool selected = c['name'] == selectedCategory;

                return GestureDetector(
                  onTap: () => _filterByCategory(c['name']!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: selected
                              ? Colors.deepOrange
                              : Colors.orange.shade100,
                          child: Text(
                            c['icon']!,
                            style: TextStyle(
                              fontSize: 22,
                              color: selected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selected
                                ? Colors.deepOrange
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.58,
            ),
            itemBuilder: (_, i) {
              final p = filteredProducts[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: p),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          p['image_url'] ?? '',
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 60),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p['name'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${MoneyFormatter.format(p['price'])}đ',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          size: 18,
                          color: Colors.deepOrange,
                        ),
                        onPressed: () {
                          // ❌ ADMIN KHÔNG ĐƯỢC THÊM GIỎ
                          if (AppAuthState.role == 'admin') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Admin không thể thêm sản phẩm vào giỏ hàng'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // ✅ USER → THÊM GIỎ BÌNH THƯỜNG
                          _addToCart(p);
                        },
                      ),

                    ),


                      ],
                    ),
                  ),
                ),
              );

            },
          ),
        ],
      ),
    );
  }
}
