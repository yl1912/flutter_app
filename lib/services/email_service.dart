import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static Future<bool> sendOtp(String email, String otp) async {
    const apiKey = "re_7Dzrfy8H_7ZYWiMhWHnAWGVuhFmseWv8C";

    print("🔹 Gửi email OTP tới: $email");
    print("🔹 OTP cần gửi: $otp");

    try {
      final response = await http.post(
        Uri.parse("https://api.resend.com/emails"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "from": "ShopMall OTP <onboarding@resend.dev>", // ✔ đúng domain
          "to": email,
          "subject": "Mã OTP xác thực tài khoản",
          "html": """
            <h2>Chào mừng bạn!</h2>
            <p>Mã OTP xác thực của bạn:</p>
            <h1><b>$otp</b></h1>
            <p>Mã hết hạn sau 2 phút.</p>
          """
        }),
      );

      print("📌 HTTP status: ${response.statusCode}");
      print("📌 Resend response: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Lỗi gửi mail: $e");
      return false;
    }
  }
}
