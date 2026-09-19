import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient;
  AppUser? _user;
  bool _initialized = false;

  AuthService(this._apiClient) {
    _apiClient.onUnauthorized = logout;
  }

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get initialized => _initialized;

  /// Recharge la session stockée localement au démarrage de l'app.
  Future<void> restoreSession() async {
    final token = await _apiClient.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user');
      if (raw != null) {
        _user = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _handleAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.readableError(e));
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      });
      await _handleAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.readableError(e));
    }
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    await _apiClient.saveToken(data['token'] as String);
    _user = AppUser(
      userId: data['userId'] as int,
      fullName: data['fullName'] as String,
      email: data['email'] as String,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _user = null;
    notifyListeners();
  }
}
