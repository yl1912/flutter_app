import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailCtrl = TextEditingController();
  bool _loading = false;

  SupabaseClient get supabase => Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("Quên mật khẩu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Khôi phục mật khẩu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text("Nhập email đã đăng ký để nhận link đặt lại mật khẩu."),
            const SizedBox(height: 20),

            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ))
                    : const Text(
                  "Gửi email đặt lại mật khẩu",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
              child: const Text(
                "Quay lại đăng nhập",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      _showSnack("⚠ Vui lòng nhập email", Colors.red);
      return;
    }

    if (!email.contains("@")) {
      _showSnack("⚠ Email không hợp lệ!", Colors.red);
      return;
    }

    setState(() => _loading = true);

    try {
      /// 🔹 Supabase gửi link đặt mật khẩu mới
      await supabase.auth.resetPasswordForEmail(email);

      _showSnack(
        "📩 Đã gửi email đặt lại mật khẩu, vui lòng kiểm tra hộp thư!",
        Colors.green,
      );

      /// 🔹 Tự quay về trang login
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);

    } on AuthException catch (e) {
      _showSnack("⛔ ${e.message}", Colors.red);
    } catch (e) {
      _showSnack("❌ Có lỗi xảy ra, vui lòng thử lại!", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}
