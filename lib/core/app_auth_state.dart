// lib/core/app_auth_state.dart

class AppAuthState {
  static bool isLoggedIn = false;
  static String? currentUserEmail;
  static String? currentUserId;

  /// role: 'user' | 'admin'
  static String role = 'user';

  /// ✅ Set user sau khi login (nhớ truyền userRole từ bảng profiles)
  static void setUser({
    required String email,
    required String id,
    String userRole = 'user',
  }) {
    isLoggedIn = true;
    currentUserEmail = email;
    currentUserId = id;
    role = (userRole.isNotEmpty) ? userRole : 'user';
  }

  /// ✅ Update từng phần
  static void update({
    bool? loggedIn,
    String? email,
    String? userId,
    String? roleValue,
  }) {
    if (loggedIn != null) isLoggedIn = loggedIn;
    if (email != null) currentUserEmail = email;
    if (userId != null) currentUserId = userId;
    if (roleValue != null && roleValue.isNotEmpty) role = roleValue;
  }

  /// ✅ Clear state khi logout
  static void logout() {
    isLoggedIn = false;
    currentUserEmail = null;
    currentUserId = null;
    role = 'user';
  }

  /// =========================
  /// Helper tiện dùng
  /// =========================

  static bool get isAdmin => role == 'admin';
  static bool get isUser => role == 'user';

  /// Debug nhanh
  static String debugInfo() {
    return 'loggedIn=$isLoggedIn | id=$currentUserId | email=$currentUserEmail | role=$role';
  }
}
