import 'package:flutter/material.dart';
import '../api/UserAPIService.dart';
import '../model/User.dart';
import '../view/AddUserScreen.dart';
import '../view/EditUserScreen.dart';
import '../view/UserListItem.dart';

class UserListScreen extends StatefulWidget {
  final Function onLogout; // Thêm hàm xử lý đăng xuất

  UserListScreen({required this.onLogout});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = UserAPIService.instance.getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách người dùng'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
          // Thêm menu tùy chọn
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Không có người dùng nào'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return UserListItem(
                  user: user,
                  onDelete: () async {
                    await UserAPIService.instance.deleteUser(user.id!);
                    _refreshUsers();
                  },
                  onEdit: () async {
                    // Navigate to edit screen
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(user: user),
                      ),
                    );
                    if (updated == true) {
                      _refreshUsers();
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUserScreen(),
            ),
          );
          if (created == true) {
            _refreshUsers();
          }
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onLogout(); // Gọi hàm đăng xuất
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}