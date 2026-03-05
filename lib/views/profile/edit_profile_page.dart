import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  File? avatarFile;
  String? avatarUrl;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select('full_name, phone, avatar_url')
        .eq('id', user.id)
        .single();

    nameCtrl.text = data['full_name'] ?? '';
    phoneCtrl.text = data['phone'] ?? '';
    avatarUrl = data['avatar_url'];

    setState(() => loading = false);
  }

  // ================= PICK AVATAR =================
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        avatarFile = File(picked.path);
      });
    }
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      setState(() => loading = true);

      String? uploadedAvatarUrl = avatarUrl;

      // 🔹 Upload avatar nếu có chọn ảnh mới
      if (avatarFile != null) {
        final path = 'avatars/${user.id}.jpg';

        await supabase.storage
            .from('avatars')
            .upload(
          path,
          avatarFile!,
          fileOptions: const FileOptions(upsert: true),
        );

        uploadedAvatarUrl = supabase.storage
            .from('avatars')
            .getPublicUrl(path);
      }

      // 🔹 Update profile
      await supabase.from('profiles').update({
        'full_name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'avatar_url': uploadedAvatarUrl,
      }).eq('id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Cập nhật hồ sơ thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.deepOrange,
                backgroundImage: avatarFile != null
                    ? FileImage(avatarFile!)
                    : (avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null) as ImageProvider?,
                child: avatarFile == null && avatarUrl == null
                    ? const Icon(Icons.camera_alt,
                    color: Colors.white, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Chạm để đổi ảnh'),

            const SizedBox(height: 24),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Lưu thay đổi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
