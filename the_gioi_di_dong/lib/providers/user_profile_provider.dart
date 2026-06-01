import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';

class UserProfileProvider extends ChangeNotifier {
  static const _nameKey = 'receiverName';
  static const _phoneKey = 'receiverPhone';
  static const _addressKey = 'receiverAddress';
  static const _noteKey = 'receiverNote';
  static const _emailKey = 'userEmail';
  static const _accountIdKey = 'maTk';

  String _name = '';
  String _phone = '';
  String _address = '';
  String _note = '';
  String _email = '';
  String _maTk = '';
  bool _isLoaded = false;

  String get name => _name;
  String get phone => _phone;
  String get address => _address;
  String get note => _note;
  String get email => _email;
  String get maTk => _maTk;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString(_emailKey) ?? '';
    _maTk = prefs.getString(_accountIdKey) ?? '';
    _name = prefs.getString(_nameKey) ?? _name;
    _phone = prefs.getString(_phoneKey) ?? _phone;
    _address = prefs.getString(_addressKey) ?? _address;
    _note = prefs.getString(_noteKey) ?? _note;

    if (_maTk.isNotEmpty) {
      final serverProfile = await ApiService.fetchUserProfile(_maTk);
      if (serverProfile != null) {
        _applyServerProfile(serverProfile);
        await _saveLocalProfile(prefs);
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    await _save(name: name, phone: phone, address: address, note: _note);
  }

  Future<void> saveReceiver({
    required String name,
    required String phone,
    required String address,
    required String note,
  }) async {
    await _save(name: name, phone: phone, address: address, note: note);
  }

  Future<void> _save({
    required String name,
    required String phone,
    required String address,
    required String note,
  }) async {
    _name = name.trim();
    _phone = phone.trim();
    _address = address.trim();
    _note = note.trim();

    final prefs = await SharedPreferences.getInstance();
    _maTk = prefs.getString(_accountIdKey) ?? _maTk;

    if (_maTk.isNotEmpty) {
      final serverProfile = await ApiService.updateUserProfile(
        maTk: _maTk,
        hoTen: _name,
        soDienThoai: _phone,
        diaChi: _address,
      );
      if (serverProfile != null) {
        _applyServerProfile(serverProfile);
      }
    }

    await _saveLocalProfile(prefs);
    notifyListeners();
  }

  void _applyServerProfile(Map<String, dynamic> data) {
    _email = data['email']?.toString() ?? _email;
    _name = data['hoTen']?.toString().trim() ?? _name;
    _phone = data['soDienThoai']?.toString().trim() ?? _phone;
    _address = data['diaChi']?.toString().trim() ?? _address;
  }

  Future<void> _saveLocalProfile(SharedPreferences prefs) async {
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_phoneKey, _phone);
    await prefs.setString(_addressKey, _address);
    await prefs.setString(_noteKey, _note);
  }
}
