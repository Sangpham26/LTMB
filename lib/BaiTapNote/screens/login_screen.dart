import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/note_database_helper.dart'; // Import helper

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isLogin = true; // True for login, false for signup

  Future<void> _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    if (!isValid) {
      return;
    }

    // Bắt đầu loading
    // Kiểm tra mounted trước khi gọi setState
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      UserCredential userCredential;
      if (_isLogin) {
        // Login
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Signup
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Xác thực thất bại.'; // Thông báo lỗi chung hơn

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        // Dừng loading khi có lỗi
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Xử lý các lỗi khác không phải FirebaseAuthException
      print("Error during authentication: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã xảy ra lỗi không mong muốn.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        // Dừng loading khi có lỗi
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Phần còn lại của hàm build giữ nguyên như trước
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ Theme
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 30.0,
              ), // Điều chỉnh padding
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30), // Tăng khoảng cách
                    TextFormField(
                      controller: _emailController,
                      key: const ValueKey('email'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Vui lòng nhập địa chỉ email hợp lệ.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next, // Chuyển focus khi nhấn next
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Theme.of(context).primaryColor,
                        ), // Icon khác
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true, // Thêm nền nhẹ
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      key: const ValueKey('password'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự.';
                        }
                        return null;
                      },
                      obscureText: true,
                      textInputAction:
                          TextInputAction.done, // Hoàn thành khi nhấn done
                      onFieldSubmitted:
                          (_) =>
                              _submitAuthForm(), // Gửi form khi nhấn done trên bàn phím
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).primaryColor,
                        ), // Icon khác
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 30), // Tăng khoảng cách
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 15,
                          ), // Tăng padding nút
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor:
                              Theme.of(context).primaryColor, // Màu nút chính
                          foregroundColor: Colors.white, // Màu chữ nút
                        ),
                        onPressed: _submitAuthForm,
                        child: Text(
                          _isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                          style: const TextStyle(
                            fontSize: 16,
                          ), // Tăng cỡ chữ nút
                        ),
                      ),
                    const SizedBox(height: 20), // Tăng khoảng cách
                    if (!_isLoading)
                      TextButton(
                        child: Text(
                          _isLogin
                              ? 'Chưa có tài khoản? Đăng ký ngay'
                              : 'Đã có tài khoản? Đăng nhập',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {
                          // Kiểm tra mounted trước khi gọi setState
                          if (mounted) {
                            setState(() {
                              _isLogin = !_isLogin;
                              // Xóa lỗi validation cũ khi chuyển form
                              _formKey.currentState?.reset();
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
