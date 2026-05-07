import 'package:hive_flutter/hive_flutter.dart';
import '../domain/user_model.dart';

class AuthRepository {
  static const String _usersBox = 'users';
  static const String _sessionBox = 'session';

  Future<UserModel?> login(String email, String password) async {
    final box = Hive.box<UserModel>(_usersBox);
    try {
      final user = box.values.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      // Save session
      Hive.box<String>(_sessionBox).put('currentUser', user.email);
      return user;
    } catch (e) {
      throw Exception('Email atau password salah');
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    final box = Hive.box<UserModel>(_usersBox);
    // Check if email already exists
    if (box.values.any((u) => u.email == email)) {
      throw Exception('Email sudah terdaftar');
    }
    
    final newUser = UserModel(name: name, email: email, password: password);
    await box.add(newUser);
    
    // Save session
    Hive.box<String>(_sessionBox).put('currentUser', newUser.email);
    return newUser;
  }

  Future<void> logout() async {
    await Hive.box<String>(_sessionBox).delete('currentUser');
  }

  Future<UserModel> updateProfile(String name, String? avatar) async {
    final currentUser = getCurrentUser();
    if (currentUser == null) throw Exception('No user logged in');
    
    final box = Hive.box<UserModel>(_usersBox);
    final index = box.values.toList().indexWhere((u) => u.email == currentUser.email);
    
    if (index == -1) throw Exception('User not found');
    
    final updatedUser = currentUser.copyWith(name: name, avatar: avatar);
    await box.putAt(index, updatedUser);
    return updatedUser;
  }

  UserModel? getCurrentUser() {
    final sessionBox = Hive.box<String>(_sessionBox);
    final email = sessionBox.get('currentUser');
    if (email != null) {
      final box = Hive.box<UserModel>(_usersBox);
      try {
        return box.values.firstWhere((u) => u.email == email);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
