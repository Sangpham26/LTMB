import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'note_list_screen.dart'; // Import màn hình danh sách note để điều hướng tới sau khi thành công

// Định nghĩa LoginScreen là một StatefulWidget vì trạng thái của nó (như đang tải, chế độ đăng nhập/đăng ký) có thể thay đổi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// Lớp State chứa trạng thái và logic của LoginScreen.
class _LoginScreenState extends State<LoginScreen> {
  // Instance của Firebase Authentication để tương tác với dịch vụ xác thực.
  final _auth = FirebaseAuth.instance;
  // Controller để quản lý và lấy dữ liệu từ TextField Email.
  final _emailController = TextEditingController();
  // Controller để quản lý và lấy dữ liệu từ TextField Mật khẩu.
  final _passwordController = TextEditingController();

  // Biến boolean để xác định màn hình đang ở chế độ Đăng nhập (true) hay Đăng ký (false).
  bool _isLogin = true;
  // Biến boolean để theo dõi trạng thái đang tải (khi gọi Firebase).
  bool _isLoading = false;
  // Biến String (có thể null) để lưu và hiển thị thông báo lỗi.
  String? _errorMessage;

  // Hàm xử lý việc gửi thông tin đăng nhập/đăng ký.
  Future<void> _submit() async {
    // --- Validation (Kiểm tra dữ liệu đầu vào) ---
    final email = _emailController.text.trim(); // Lấy email và xóa khoảng trắng thừa
    final password = _passwordController.text.trim(); // Lấy mật khẩu và xóa khoảng trắng thừa

    // Kiểm tra xem email hoặc mật khẩu có bị trống không.
    if (email.isEmpty || password.isEmpty) {
      // Hiển thị SnackBar thông báo lỗi nếu thiếu thông tin.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            // Thông báo lỗi cụ thể tùy trường hợp.
            email.isEmpty && password.isEmpty
                ? 'Vui lòng nhập email và mật khẩu'
                : email.isEmpty
                ? 'Vui lòng nhập email'
                : 'Vui lòng nhập mật khẩu',
          ),
          backgroundColor: Colors.red, // Màu nền đỏ cho lỗi.
        ),
      );
      return; // Dừng hàm nếu validation thất bại.
    }

    // --- Bắt đầu quá trình xử lý ---
    setState(() {
      _isLoading = true; // Đặt trạng thái đang tải thành true để hiển thị loading indicator.
      _errorMessage = null; // Xóa thông báo lỗi cũ trước khi thử lại.
    });

    // --- Tương tác với Firebase ---
    try {
      // Kiểm tra xem đang ở chế độ đăng nhập hay đăng ký.
      if (_isLogin) {
        // Nếu là đăng nhập, gọi hàm signInWithEmailAndPassword.
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Nếu là đăng ký, gọi hàm createUserWithEmailAndPassword.
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // --- Xử lý thành công ---
      // Nếu không có lỗi xảy ra (đăng nhập/đăng ký thành công), điều hướng đến NoteListScreen.
      // pushReplacement thay thế màn hình hiện tại, người dùng không thể quay lại màn hình Login.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoteListScreen()),
      );
    } catch (e) {
      // --- Xử lý lỗi ---
      // Nếu có lỗi xảy ra trong quá trình tương tác với Firebase.
      setState(() {
        // Cập nhật errorMessage với nội dung lỗi để hiển thị trên UI.
        _errorMessage = e.toString();
      });
      // Hiển thị SnackBar với thông tin lỗi chi tiết hơn.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'), // Hiển thị lỗi cụ thể
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // --- Hoàn tất xử lý (luôn được gọi) ---
      // Khối finally luôn được thực thi dù thành công hay thất bại.
      // Đảm bảo rằng trạng thái loading được tắt đi.
      if (mounted) { // Kiểm tra xem State object còn trong cây widget không trước khi gọi setState
        setState(() {
          _isLoading = false; // Đặt trạng thái đang tải thành false.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Định nghĩa các hằng số để tái sử dụng trong UI.
    const double borderRadius = 12.0; // Bán kính bo góc.
    const double sectionSpacing = 16.0; // Khoảng cách giữa các phần tử.
    const double innerPadding = 12.0; // Padding bên trong Card.

    // Scaffold cung cấp cấu trúc cơ bản cho màn hình (AppBar, Body).
    return Scaffold(
      appBar: AppBar(
        // Tiêu đề AppBar thay đổi dựa trên chế độ (_isLogin).
        title: Text(
          _isLogin ? 'Đăng nhập' : 'Đăng ký',
          style: const TextStyle(color: Colors.white), // Màu chữ tiêu đề.
        ),
        backgroundColor: const Color(0xFF3A3A3A), // Màu nền AppBar.
        iconTheme: const IconThemeData(color: Colors.white), // Màu icon (nếu có nút back).
      ),
      // Padding bao quanh nội dung chính của màn hình.
      body: Padding(
        padding: const EdgeInsets.all(sectionSpacing),
        // Column sắp xếp các widget con theo chiều dọc.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Kéo dãn các widget con theo chiều ngang.
          children: [
            // Card chứa TextField Email.
            Card(
              elevation: 2.0, // Độ nổi của Card.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius), // Bo góc Card.
                side: const BorderSide(color: Colors.black12), // Viền mờ cho Card.
              ),
              child: Padding(
                padding: const EdgeInsets.all(innerPadding),
                // TextField cho phép người dùng nhập Email.
                child: TextField(
                  controller: _emailController, // Gắn controller để lấy dữ liệu.
                  decoration: const InputDecoration(
                    labelText: 'Email', // Nhãn hiển thị phía trên khi focus.
                    border: OutlineInputBorder(), // Viền xung quanh TextField.
                  ),
                  keyboardType: TextInputType.emailAddress, // Gợi ý bàn phím phù hợp.
                ),
              ),
            ),
            // Khoảng trống giữa hai Card.
            const SizedBox(height: sectionSpacing),
            // Card chứa TextField Mật khẩu.
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: const BorderSide(color: Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(innerPadding),
                // TextField cho phép người dùng nhập Mật khẩu.
                child: TextField(
                  controller: _passwordController, // Gắn controller.
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Ẩn các ký tự nhập vào.
                ),
              ),
            ),
            // Khoảng trống.
            const SizedBox(height: sectionSpacing),
            // Hiển thị thông báo lỗi nếu _errorMessage không null.
            if (_errorMessage != null)
              Padding( // Thêm Padding để thông báo lỗi không sát nút
                padding: const EdgeInsets.only(bottom: sectionSpacing),
                child: Text(
                  _errorMessage!, // Dấu ! khẳng định _errorMessage không null ở đây.
                  style: const TextStyle(color: Colors.red), // Màu chữ đỏ cho lỗi.
                  textAlign: TextAlign.center, // Căn giữa text lỗi
                ),
              ),
            // Không cần SizedBox ở đây nữa vì đã thêm Padding cho Text lỗi
            // const SizedBox(height: sectionSpacing),
            // Nút chính để thực hiện hành động Đăng nhập/Đăng ký.
            ElevatedButton(
              // Nếu đang tải (_isLoading = true), nút bị vô hiệu hóa (onPressed = null).
              // Nếu không, khi nhấn sẽ gọi hàm _submit.
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A3A3A), // Màu nền nút.
                foregroundColor: Colors.white, // Màu chữ/icon trên nút.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius), // Bo góc nút.
                ),
              ),
              // Nội dung bên trong nút.
              child: _isLoading
              // Nếu đang tải, hiển thị CircularProgressIndicator.
                  ? const SizedBox( // Đặt kích thước cho Indicator
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3, // Làm nét vẽ mỏng hơn một chút
                ),
              )
              // Nếu không tải, hiển thị Text tương ứng với chế độ.
                  : Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
            ),
            // Khoảng trống.
            const SizedBox(height: sectionSpacing),
            // Nút dạng Text để chuyển đổi giữa chế độ Đăng nhập và Đăng ký.
            TextButton(
              onPressed: () {
                // Khi nhấn nút này:
                setState(() {
                  _isLogin = !_isLogin; // Đảo ngược trạng thái _isLogin.
                  _errorMessage = null; // Xóa thông báo lỗi cũ khi chuyển chế độ.
                  // Cân nhắc xóa nội dung text field khi chuyển chế độ (tùy chọn):
                  // _emailController.clear();
                  // _passwordController.clear();
                });
              },
              // Text hiển thị trên nút, thay đổi tùy theo chế độ _isLogin.
              child: Text(
                _isLogin
                    ? 'Chưa có tài khoản? Đăng ký'
                    : 'Đã có tài khoản? Đăng nhập',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm dispose được gọi khi State object bị xóa khỏi cây widget.
  @override
  void dispose() {
    // Giải phóng tài nguyên của các TextEditingController để tránh rò rỉ bộ nhớ.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose(); // Gọi hàm dispose của lớp cha.
  }
}