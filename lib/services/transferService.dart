import 'package:supabase_flutter/supabase_flutter.dart';

class TransferService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Load user data including wallet balance
  Future<Map<String, dynamic>?> loadUserData(String userId) async {
    try {
      final userData = await _supabase
          .from('users')
          .select()
          .eq('auth_user_id', userId)
          .single();

      final walletData = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', userData['id'])
          .single();

      return {
        'user': userData,
        'wallet': walletData,
      };
    } catch (e) {
      return null;
    }
  }

  // Verify transaction PIN
  Future<bool> verifyTransactionPin(String userId, String pin) async {
    try {
      final user = await _supabase
          .from('users')
          .select('pin_hash')
          .eq('auth_user_id', userId)
          .single();

      // In a real app, you would verify the hashed PIN here
      // For simplicity, we'll just check if the PIN is 4 digits
      return pin.length == 4;
    } catch (e) {
      return false;
    }
  }

  // Process the transfer between users
Future<Map<String, dynamic>> processTransfer({
  required String recipientIdentifier,
  required double amount,
  required String note,
  required String currentUserId,
}) async {
  try {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    await _supabase.rpc('transfer_funds', params: {
      'sender_auth_id': currentUser.id,
      'recipient_identifier': recipientIdentifier,
      'amount': amount,
      'description': note,
    });

    return {'success': true, 'message': 'Transfer successful'};
  } catch (e) {
    return {'success': false, 'message': 'Transfer failed: ${e.toString()}'};
  }
}
}