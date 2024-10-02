import 'package:notification_app/shared/models/user.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<void> logout();
}