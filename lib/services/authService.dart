import 'package:supabase_flutter/supabase_flutter.dart';

// Result class to handle responses
class AuthResult {
  final bool success;
  final String? message;
  final dynamic data;

  AuthResult({
    required this.success,
    this.message,
    this.data,
  });
}

// Auth service interface
abstract class AuthService {
  Future<AuthResult> signUp({
    required String fullName,
    required String username,
    required String email,
    required String telephone,
    required String password,
    required String pin,
  });
  
  Future<AuthResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> logout();
  Future<AuthResult> resetPassword(String email);
  Future<bool> isAuthenticated();
}

// Auth service implementation using Supabase
class AuthServiceImpl implements AuthService {
  final SupabaseClient _supabase;
  
  AuthServiceImpl(this._supabase);

  @override
  Future<AuthResult> signUp({
    required String fullName,
    required String username,
    required String email,
    required String telephone,
    required String password,
    required String pin,
  }) async {
    try {
      // First check if user exists with same email, username or telephone
      final existingUsers = await _supabase
          .from('users')
          .select()
          .or('email.eq.${email.toLowerCase()},telephone.eq.$telephone,username.eq.${username.toLowerCase()}');

      if (existingUsers.isNotEmpty) {
        final existingUser = existingUsers.first;
        if (existingUser['email'].toString().toLowerCase() == email.toLowerCase()) {
          return AuthResult(
            success: false,
            message: 'This email address is already registered. Please try signing in instead',
          );
        } else if (existingUser['telephone'] == telephone) {
          return AuthResult(
            success: false,
            message: 'This phone number is already registered. Please use a different number',
          );
        } else if (existingUser['username'].toString().toLowerCase() == username.toLowerCase()) {
          return AuthResult(
            success: false,
            message: 'This username is already taken. Please choose a different one',
          );
        }
      }

      // Sign up with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return AuthResult(
          success: false,
          message: 'We couldn\'t create your account at this time. Please try again',
        );
      }

      // Insert user data
      try {
        await _supabase
            .from('users')
            .insert({
              'email': email.toLowerCase(),
              'username': username.toLowerCase(),
              'full_name': fullName,
              'telephone': telephone,
              'pin_hash': pin,
              'auth_user_id': authResponse.user!.id,
            });

        return AuthResult(
          success: true,
          message: 'Welcome! Your account has been created. Please check your email to verify your account.',
        );
      } catch (dbError) {
        print('Database error: $dbError');
        await _supabase.auth.admin.deleteUser(authResponse.user!.id);
        return AuthResult(
          success: false,
          message: 'We encountered an issue while setting up your profile. Please try again',
        );
      }
    } catch (e) {
      print('Error in signUp: $e');
      String errorMessage = 'Something went wrong. ';
      if (e.toString().contains('network')) {
        errorMessage += 'Please check your internet connection and try again.';
      } else {
        errorMessage += 'Please try again or contact support if the problem persists.';
      }
      return AuthResult(
        success: false,
        message: errorMessage,
      );
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult(
          success: false,
          message: 'The email or password you entered is incorrect. Please try again',
        );
      }

      // Fetch user data
      final userData = await _supabase
          .from('users')
          .select()
          .eq('auth_user_id', response.user!.id)
          .single();

      return AuthResult(
        success: true,
        message: 'Welcome back!',
        data: userData,
      );
    } on AuthException catch (e) {
      String message = 'Unable to sign in. ';
      if (e.message.contains('Invalid login')) {
        message = 'The email or password you entered is incorrect. Please try again';
      } else if (e.message.contains('not confirmed')) {
        message = 'Please verify your email address before signing in';
      } else {
        message += 'Please check your credentials and try again';
      }
      return AuthResult(
        success: false,
        message: message,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'We\'re having trouble connecting. Please check your internet connection and try again',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return AuthResult(
        success: true,
        message: 'Password reset instructions have been sent to your email',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Unable to send reset instructions. Please check your email and try again',
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentUser != null;
  }
}

// Singleton manager for AuthService
class AuthServiceManager {
  static AuthService? _instance;
  
  static AuthService get instance {
    _instance ??= AuthServiceImpl(
      Supabase.instance.client,
    );
    return _instance!;
  }
}