import 'dart:convert';

import 'package:despesa_app/model/user.dart';
import 'package:http/http.dart' as http;

class Authentication {

  String _token;
  int _expiresIn;

  User _currentUser;

  Future<User> get currentUser async {
    if (_currentUser != null) return _currentUser;
    _currentUser = await _me();
    return _currentUser;
  }

  Authentication._privateConstructor();
  static final Authentication instance = Authentication._privateConstructor();

  static final String _baseUrl = 'http://10.0.2.2:5000/auth';

  Future<Map<String, dynamic>> signUp(String fullName, String username, String password, String confirmPassword) async {
    final response = await http.post(
      '$_baseUrl/signup/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String> {
        'full_name': fullName,
        'username': username,
        'password': password,
        'confirm_password': confirmPassword
      }),
    );

    Map<String, dynamic> body = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true
      };
    }

    return {
      'success': false,
      'message': body['message']
    };
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      '$_baseUrl/token/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'username': username,
        'password': password
      }),
    );

    Map<String, dynamic> body = json.decode(response.body);

    if (response.statusCode == 200) {
      _token = body['token'];
      _expiresIn = body['expires_in'];

      return {
        'success': true
      };
    }

    return {
      'success': false,
      'message': body['message']
    };
  }

  Future<User> _me() async {
    final response = await http.get(
      '$_baseUrl/me/',
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(response.body);
      return User.fromJson(body);
    }

    throw Exception('TODO me exception');
  }
}