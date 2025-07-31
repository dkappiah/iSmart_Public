import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mini_mobile_digital_wallet/services/authService.dart';

class ProfileService {
  final SupabaseClient _supabase;
  final AuthService _authService;

  ProfileService()
      : _supabase = Supabase.instance.client,
        _authService = AuthServiceManager.instance;

  // Get current user profile data
  Future<Map<String, dynamic>> getProfileData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('users')
          .select()
          .eq('auth_user_id', userId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch profile data: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? telephone,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (username != null) updates['username'] = username.toLowerCase();
      if (telephone != null) updates['telephone'] = telephone;

      await _supabase
          .from('users')
          .update(updates)
          .eq('auth_user_id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Change PIN
  Future<void> changePin(String newPin) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('users')
          .update({'pin_hash': newPin})
          .eq('auth_user_id', userId);
    } catch (e) {
      throw Exception('Failed to change PIN: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _authService.logout();
  }

  // Get app version and about info
  Future<Map<String, dynamic>> getAppInfo() async {
    // This could be expanded to fetch from a remote config if needed
    return {
      'version': '1.0.0',
      'buildNumber': '1',
      'aboutText': 'Mini Mobile Digital Wallet\n\n'
          'A secure and convenient way to manage your digital transactions.\n\n'
          '© 2023 Digital Wallet Inc. All rights reserved.',
    };
  }
}