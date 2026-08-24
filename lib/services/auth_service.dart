import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/access_control.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:9090';
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    const demoAccounts = {
      'admin': {
        'password': '1234',
        'name': '김로빈',
        'role': 'ADMIN',
      },
      'staff': {
        'password': '1234',
        'name': '박로빈',
        'role': 'EMPLOYEE',
      },
      'dealer': {
        'password': '1234',
        'name': '이대리점',
        'role': 'DEALER',
      },
      'kimdealer': {
        'password': '1234',
        'name': '김대리점',
        'role': 'DEALER',
      },
    };
    final demo = demoAccounts[username];
    if (demo != null) {
      RobinEmployee? employee;
      for (final item in robinEmployees.value) {
        if (item.id == username) employee = item;
      }
      if (employee == null) {
        return {'success': false, 'message': '삭제되었거나 존재하지 않는 계정입니다.'};
      }
      if (!employee.active) {
        return {'success': false, 'message': '비활성화된 계정입니다. 관리자에게 문의하세요.'};
      }
      if (demo['password'] != password) {
        return {'success': false, 'message': '아이디 또는 비밀번호가 올바르지 않습니다.'};
      }
      return {
        'success': true,
        'name': demo['name'],
        'role': demo['role'],
        'username': username,
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'name': data['name'],
          'role': data['role'],
          'username': data['username'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? '로그인에 실패했습니다.'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요'};
    }
  }
}
