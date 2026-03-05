import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_page.dart';
import 'help_center_page.dart';
import 'chat_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  late final RealtimeChannel _orderChannel;

  String fullName = 'Người dùng';
  String email = '';
  String? avatarUrl;
  String role = 'user';
  int pendingOrders = 0;
  int packedOrders = 0;
  int shippingOrders = 0;
  int deliveredOrders = 0;
  int canceledOrders = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadOrderCounts();

    _orderChannel = supabase
        .channel('orders-realtime')
        .onPostgresChanges(
      event: PostgresChangeEvent.all, // 👈 INSERT / UPDATE / DELETE
      schema: 'public',
      table: 'orders',
      callback: (payload) {
        // 👉 MỖI KHI ĐƠN THAY ĐỔI → LOAD LẠI TOÀN BỘ
        _loadOrderCounts();
      },
    )
        .subscribe();
  }

  /// =========================
  /// LOAD PROFILE
  /// =========================
  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('profiles')
        .select('full_name, email, avatar_url, role')
        .eq('id', user.id)
        .single();

    setState(() {
      fullName = res['full_name'] ?? 'Người dùng';
      email = res['email'] ?? '';
      avatarUrl = res['avatar_url'];
      role = res['role'] ?? 'user';
    });
  }

  /// =========================
  /// LOAD ĐƠN CHỜ XÁC NHẬN
  /// =========================
  Future<void> _loadOrderCounts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('orders')
        .select('status')
        .eq('user_id', user.id);

    final list = List<Map<String, dynamic>>.from(res);

    setState(() {
      pendingOrders =
          list.where((o) => o['status'] == 'Đang chờ xác nhận').length;

      packedOrders =
          list.where((o) => o['status'] == 'Đã gói hàng').length;

      shippingOrders =
          list.where((o) => o['status'] == 'Đang giao hàng').length;

      deliveredOrders =
          list.where((o) => o['status'] == 'Đã giao hàng').length;

      canceledOrders =
          list.where((o) => o['status'] == 'Đã hủy').length;

      loading = false;
    });
  }


  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (_) => false,
    );
  }

  @override
  void dispose() {
    supabase.removeChannel(_orderChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// ===== AVATAR + NAME =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.deepOrange,
                    backgroundImage:
                    avatarUrl != null && avatarUrl!.isNotEmpty
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person,
                        size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(email,
                          style:
                          const TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const EditProfilePage(),
                            ),
                          );
                          if (updated == true) {
                            _loadProfile();
                          }
                        },
                        child: const Text(
                          'Xem & chỉnh sửa hồ sơ',
                          style:
                          TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const Divider(height: 40),

            /// ===== ĐƠN MUA (❌ ADMIN KHÔNG THẤY) =====
            if (role != 'admin')
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Đơn mua',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text('Xem lịch sử mua hàng',
                            style: TextStyle(color: Colors.grey))
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 🔵 CHỜ XÁC NHẬN
                        _orderIcon(
                          icon: Icons.wallet,
                          label: 'Chờ xác nhận',
                          badge: pendingOrders,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/order-status',
                              arguments: 'Đang chờ xác nhận',
                            );
                          },
                        ),

                        // 🟠 CHỜ LẤY HÀNG
                        _orderIcon(
                          icon: Icons.inventory_2_outlined,
                          label: 'Chờ lấy hàng',
                          badge: packedOrders,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/order-status',
                              arguments: 'Đã gói hàng',
                            );
                          },
                        ),

                        // 🚚 CHỜ GIAO
                        _orderIcon(
                          icon: Icons.local_shipping_outlined,
                          label: 'Chờ giao',
                          badge: shippingOrders,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/order-status',
                              arguments: 'Đang giao hàng',
                            );
                          },
                        ),

                        // ⭐ ĐÁNH GIÁ
                        _orderIcon(
                          icon: Icons.cancel_outlined,
                          label: 'Đã hủy',
                          badge: canceledOrders,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/order-status',
                              arguments: 'Đã hủy',
                            );
                          },
                        ),

                      ],
                    ),

                  ],
                ),
              ),


            /// ===== ADMIN ONLY =====
            if (role == 'admin')
              ListTile(
                leading: const Icon(Icons.store,
                    color: Colors.deepOrange),
                title: const Text('Quản lý bán hàng'),
                trailing:
                const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                      context, '/admin-dashboard');
                },
              ),

            /// ===== MENU CHUNG =====
            ListTile(
              leading: const Icon(Icons.help_outline,
                  color: Colors.deepOrange),
              title: const Text('Trung tâm trợ giúp'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const HelpCenterPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat,
                  color: Colors.deepOrange),
              title: const Text('Trò chuyện ShopMall'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChatPage()),
              ),
            ),
            /// ===== LOGOUT =====
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize:
                  const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _orderIcon({
    required IconData icon,
    required String label,
    int badge = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          if (badge > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
