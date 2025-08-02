import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class TransferService {
  final SupabaseClient supabase;

  TransferService({required SupabaseClient client}) : supabase = client;

  Future<Map<String, dynamic>?> loadUserData(String userId) async {
    try {
      final userResponse = await supabase
          .from('users')
          .select()
          .eq('auth_user_id', userId)
          .single();

      final walletResponse = await supabase
          .from('wallets')
          .select()
          .eq('user_id', userResponse['id'])
          .single();

      return {
        'user': userResponse,
        'wallet': walletResponse,
      };
    } catch (e) {
      throw Exception('Failed to load user data: ${e.toString()}');
    }
  }

  String _hashPin(String pin, String userId) {
    final salt = 'digipurse_salt_$userId';
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _comparePlainPin(String inputPin, String storedPin) {
    return inputPin == storedPin;
  }

  Future<bool> verifyTransactionPin(String userId, String pin) async {
    try {
      if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
        return false;
      }

      final response = await supabase
          .from('users')
          .select('pin_hash, auth_user_id')
          .eq('auth_user_id', userId)
          .single();

      final storedHash = response['pin_hash'] as String?;
      if (storedHash == null || storedHash.isEmpty) {
        return false;
      }

      final hashedPinWithUserId = _hashPin(pin, userId);
      if (storedHash == hashedPinWithUserId) {
        return true;
      }

      final hardcodedSalt = 'your_secure_salt_here';
      final bytes = utf8.encode(pin + hardcodedSalt);
      final hashedPinHardcoded = sha256.convert(bytes).toString();
      if (storedHash == hashedPinHardcoded) {
        return true;
      }

      if (_comparePlainPin(pin, storedHash)) {
        return true;
      }

      if (storedHash.length == 4 && RegExp(r'^\d{4}$').hasMatch(storedHash)) {
        if (pin == storedHash) {
          return true;
        }
      }

      return false;
      
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> processTransfer({
    required String recipientIdentifier,
    required double amount,
    required String note,
    required String currentUserId,
  }) async {
    try {
      final senderData = await loadUserData(currentUserId);
      if (senderData == null) {
        return {
          'success': false,
          'message': 'Sender account not found',
        };
      }

      final senderId = senderData['user']['id'] as String;
      final senderWalletId = senderData['wallet']['id'] as String;
      final senderBalance = (senderData['wallet']['balance'] as num).toDouble();

      if (amount <= 0) {
        return {
          'success': false,
          'message': 'Invalid transfer amount',
        };
      }

      if (senderBalance < amount) {
        return {
          'success': false,
          'message': 'Insufficient funds. Available balance: GHS ${senderBalance.toStringAsFixed(2)}',
        };
      }

      List<Map<String, dynamic>> recipientResults;
      try {
        recipientResults = await supabase
            .from('users')
            .select('id, auth_user_id, email, username, full_name')
            .or('email.eq.$recipientIdentifier,username.eq.$recipientIdentifier');
            
        if (recipientResults.isEmpty) {
          return {
            'success': false,
            'message': 'Recipient not found. Please check the username or email.',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Error finding recipient: ${e.toString()}',
        };
      }

      final recipientData = recipientResults.first;
      final recipientId = recipientData['id'] as String;

      if (senderId == recipientId) {
        return {
          'success': false,
          'message': 'You cannot transfer money to yourself',
        };
      }

      final recipientWalletResponse = await supabase
          .from('wallets')
          .select()
          .eq('user_id', recipientId);

      if (recipientWalletResponse.isEmpty) {
        return {
          'success': false,
          'message': 'Recipient wallet not found',
        };
      }

      final recipientWallet = recipientWalletResponse.first;
      final recipientWalletId = recipientWallet['id'] as String;
      final recipientBalance = (recipientWallet['balance'] as num).toDouble();

      final referenceNumber = 'TRF-${DateTime.now().millisecondsSinceEpoch}';

      try {
        final transactionResponse = await supabase.from('transactions').insert({
          'user_id': senderId,
          'transaction_type': 'transfer',
          'amount': amount,
          'description': note.isNotEmpty ? note : 'Money transfer',
          'reference_number': referenceNumber,
          'recipient_id': recipientId,
          'recipient_email': recipientData['email'],
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        }).select('id').single();

        final transactionId = transactionResponse['id'];

        await supabase
            .from('wallets')
            .update({
              'balance': senderBalance - amount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', senderWalletId);

        await supabase.from('wallet_transaction_logs').insert({
          'wallet_id': senderWalletId,
          'transaction_id': transactionId,
          'amount': -amount,
          'balance_before': senderBalance,
          'balance_after': senderBalance - amount,
        });

        await supabase
            .from('wallets')
            .update({
              'balance': recipientBalance + amount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', recipientWalletId);

        await supabase.from('wallet_transaction_logs').insert({
          'wallet_id': recipientWalletId,
          'transaction_id': transactionId,
          'amount': amount,
          'balance_before': recipientBalance,
          'balance_after': recipientBalance + amount,
        });

        return {
          'success': true,
          'message': 'Transfer of GHS ${amount.toStringAsFixed(2)} to ${recipientData['full_name']} completed successfully',
          'transaction_id': transactionId,
          'reference_number': referenceNumber,
        };

      } catch (dbError) {
        return {
          'success': false,
          'message': 'Transaction failed. Please try again.',
        };
      }

    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  Future<bool> updateTransactionPin(String userId, String newPin) async {
    try {
      if (newPin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(newPin)) {
        return false;
      }

      final hashedPin = _hashPin(newPin, userId);
      
      await supabase
          .from('users')
          .update({
            'pin_hash': hashedPin,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_user_id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }
}