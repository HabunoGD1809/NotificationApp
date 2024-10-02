import 'package:notification_app/features/auth/domain/auth_repository.dart';
import 'package:notification_app/shared/models/user.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simular retraso
    if (email == 'test@example.com' && password == 'password123') {
      return User(id: '1', email: email, name: 'Test User');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1)); // Simular retraso
  }
}