import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thêm import này

import 'firebase_options.dart';
// Đảm bảo đường dẫn import đúng với cấu trúc thư mục
import 'BaiTapNote/screens/note_list_screen.dart';
import 'BaiTapNote/screens/login_screen.dart';     // Thêm import LoginScreen
import 'BaiTapNote/database/note_database_helper.dart'; // Thêm import DB Helper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Note App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Có thể dùng primarySwatch
        primaryColor: const Color(0xFF3A3A3A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A4A4A),
          background: const Color(0xFFDCDCDC), // Màu nền cho scaffold
        ),
        scaffoldBackgroundColor: const Color(0xFFDCDCDC), // Đặt màu nền mặc định
        useMaterial3: true, // Nên sử dụng Material 3 nếu có thể
      ),
      // Thay vì home là NoteListScreen, sử dụng AuthenticationWrapper
      home: const AuthenticationWrapper(),
      debugShowCheckedModeBanner: false, // Tắt banner debug (tùy chọn)
    );
  }
}

// --- Thêm Widget AuthenticationWrapper vào đây ---
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi trạng thái đăng nhập của Firebase Auth
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Trường hợp 1: Đang kiểm tra trạng thái (kết nối)
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị màn hình loading trong khi chờ
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Trường hợp 2: Người dùng đã đăng nhập (có dữ liệu user)
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          print("AuthenticationWrapper: User is logged in - ${user.uid}");

          // Quan trọng: Khởi tạo database cho người dùng này
          // Sử dụng FutureBuilder để đảm bảo database sẵn sàng trước khi vào NoteListScreen
          return FutureBuilder<void>(
            // Gọi hàm khởi tạo DB với UID của người dùng
            future: NoteDatabaseHelper.initializeForUser(user.uid),
            builder: (context, dbSnapshot) {
              // Nếu đang chờ DB khởi tạo
              if (dbSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: Text("Đang chuẩn bị dữ liệu...")),
                );
              }
              // Nếu có lỗi khi khởi tạo DB
              if (dbSnapshot.hasError) {
                print("AuthenticationWrapper: Error initializing DB: ${dbSnapshot.error}");

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await NoteDatabaseHelper.closeDatabase(); // Đảm bảo đóng DB
                  await FirebaseAuth.instance.signOut();
                });
                return const Scaffold(
                    body: Center(child: Text("Lỗi khởi tạo dữ liệu. Vui lòng thử lại.")));
              }
              // Nếu DB đã khởi tạo thành công
              print("AuthenticationWrapper: Database initialized successfully for ${user.uid}");
              return const NoteListScreen(); // Hiển thị màn hình danh sách note
            },
          );
        }
        // Trường hợp 3: Người dùng chưa đăng nhập (không có dữ liệu user)
        else {
          print("AuthenticationWrapper: User is not logged in.");
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await NoteDatabaseHelper.closeDatabase(); // Gọi đóng DB
          });
          return const LoginScreen(); // Hiển thị màn hình đăng nhập
        }
      },
    );
  }
}