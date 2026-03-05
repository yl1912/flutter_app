import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool loading = false;

  SupabaseClient get supabase => Supabase.instance.client;

  Future<void> _register() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final confirmPass = confirmPassCtrl.text.trim();

    // ===== VALIDATE =====
    if (name.isEmpty ||
        email.isEmpty ||
        pass.isEmpty ||
        confirmPass.isEmpty) {
      _showSnack("⚠ Vui lòng nhập đầy đủ thông tin", false);
      return;
    }

    if (!email.contains("@")) {
      _showSnack("⚠ Email không hợp lệ", false);
      return;
    }

    if (pass.length < 6) {
      _showSnack("⚠ Mật khẩu phải từ 6 ký tự", false);
      return;
    }

    if (pass != confirmPass) {
      _showSnack("❌ Mật khẩu nhập lại không khớp", false);
      return;
    }

    try {
      setState(() => loading = true);

      // 🔥 ĐĂNG KÝ SUPABASE → TỰ GỬI EMAIL XÁC NHẬN
      final res = await supabase.auth.signUp(
        email: email,
        password: pass,
        data: {
          'full_name': name, // lưu metadata (optional)
        },
      );

      if (res.user == null) {
        _showSnack("🚫 Đăng ký thất bại", false);
        return;
      }

      _showSnack(
        "📩 Vui lòng kiểm tra email và bấm link xác nhận để đăng nhập",
        true,
      );

      // ⏳ quay về login sau 1.5s
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    } catch (e) {
      _showSnack("⚠ Lỗi đăng ký: $e", false);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnack(String text, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký tài khoản"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text("👤 Họ tên"),
            TextField(controller: nameCtrl),

            const SizedBox(height: 16),

            const Text("📩 Email"),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            const Text("🔐 Mật khẩu"),
            TextField(
              controller: passCtrl,
              obscureText: true,
            ),

            const SizedBox(height: 16),

            const Text("🔐 Nhập lại mật khẩu"),
            TextField(
              controller: confirmPassCtrl,
              obscureText: true,
            ),

            const SizedBox(height: 24),

            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Đăng ký",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,

                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
}
