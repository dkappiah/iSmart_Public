import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mobile_digital_wallet/providers/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({Key? key}) : super(key: key);

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String _selectedPaymentMethod = 'Mobile Money';
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _walletData;
  
  final List<String> _paymentMethods = [
    'Mobile Money',
    'Bank Transfer',
    'Debit Card',
  ];

  final List<double> _quickAmounts = [10.0, 25.0, 50.0, 100.0, 200.0, 500.0];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Fetch user data with better error handling
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (userResponse == null) {
        _showSnackBar('User profile not found. Please complete your registration.', Colors.red);
        return;
      }

      _userData = userResponse;

      // Fetch wallet data using the correct user_id from users table
      final walletResponse = await _supabase
          .from('wallets')
          .select('*')
          .eq('user_id', _userData!['id'])
          .maybeSingle();
          
      if (walletResponse == null) {
        final walletByAuthId = await _supabase
            .from('wallets')
            .select('*')
            .eq('user_id', user.id)
            .maybeSingle();
            
        if (walletByAuthId != null) {
          _walletData = walletByAuthId;
        } else {
          // Create wallet if it doesn't exist
          await _createWalletForUser(_userData!['id']);
          return; // _createWalletForUser will reload data
        }
      } else {
        _walletData = walletResponse;
      }
      
      setState(() {}); // Refresh UI with loaded data
      
    } catch (error) {
      _showSnackBar('Error loading user data: ${error.toString()}', Colors.red);
    }
  }

  Future<void> _createWalletForUser(String userId) async {
    try {
      final walletData = {
        'user_id': userId,
        'balance': 0.0,
        'currency': 'GHS', 
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _supabase
          .from('wallets')
          .insert(walletData)
          .select()
          .single();
      
      // Reload user data after creating wallet
      await _loadUserData();
      
    } catch (error) {
      _showSnackBar('Error creating wallet: ${error.toString()}', Colors.red);
    }
  }

  Future<void> _addMoney() async {
    if (_amountController.text.isEmpty) {
      _showSnackBar('Please enter an amount', Colors.red);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', Colors.red);
      return;
    }

    // Check if user and wallet data are loaded
    if (_userData == null || _walletData == null) {
      _showSnackBar('User or wallet data not loaded. Please try again.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final walletId = _walletData!['id'];
      final userId = _userData!['id'];
      final authUserId = _supabase.auth.currentUser!.id;
      
      // Update wallet balance first
      final currentBalance = (_walletData!['balance'] ?? 0).toDouble();
      final newBalance = currentBalance + amount;
      
      try {
        final walletUpdateResponse = await _supabase
            .from('wallets')
            .update({
              'balance': newBalance,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', walletId)
            .select();
      } catch (walletError) {
        throw Exception('Failed to update wallet balance: $walletError');
      }

      final now = DateTime.now().toUtc();
      
      // Generate a unique reference number
      final referenceNumber = 'ADD_${now.millisecondsSinceEpoch}';
      
      final transactionData = {
        'user_id': authUserId, 
        'transaction_type': 'add', 
        'amount': amount,
        'status': 'completed', // Set as completed immediately just to mock
        'description': _noteController.text.isEmpty 
            ? 'Money added via $_selectedPaymentMethod' 
            : _noteController.text,
        'reference_number': referenceNumber,
        'source_type': _getSourceTypeFromPaymentMethod(_selectedPaymentMethod),
        'created_at': now.toIso8601String(),
        'completed_at': now.toIso8601String(),
        'metadata': {
          'payment_method': _selectedPaymentMethod,
          'wallet_id': walletId,
          'original_balance': currentBalance,
          'new_balance': newBalance,
        },
      };

      try {
        final transactionResponse = await _supabase
            .from('transactions')
            .insert(transactionData)
            .select()
            .single();
      } catch (transactionError) {
        // Rollback wallet balance if transaction creation fails
        try {
          await _supabase
              .from('wallets')
              .update({
                'balance': currentBalance,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', walletId);
        } catch (rollbackError) {
          // Silent rollback failure - could log this in production
        }
        
        throw Exception('Failed to create transaction record: $transactionError');
      }
      
      // Update local wallet data
      _walletData!['balance'] = newBalance;

      // Show success message
      _showSnackBar(
        'Successfully added ₵${amount.toStringAsFixed(2)} to your wallet!',
        Colors.green,
      );

      // Clear form
      _amountController.clear();
      _noteController.clear();
      
      // Navigate back with success result
      Navigator.of(context).pop(true);

    } catch (error) {
      String errorMessage = 'Failed to add money. Please try again.';
      
      // Handle specific Supabase errors with more detail
      if (error is PostgrestException) {
        // Provide more specific error messages
        if (error.code == '23502') {
          errorMessage = 'Missing required field. Please check your data.';
        } else if (error.code == '23503') {
          errorMessage = 'Invalid reference. Please contact support.';
        } else if (error.code == '42703') {
          errorMessage = 'Database column not found. Please update the app.';
        } else if (error.message.isNotEmpty) {
          errorMessage = 'Database error: ${error.message}';
        } else {
          errorMessage = 'Database error occurred. Code: ${error.code ?? "unknown"}';
        }
      } else if (error is Exception) {
        errorMessage = error.toString();
      }
      
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getSourceTypeFromPaymentMethod(String paymentMethod) {
    switch (paymentMethod) {
      case 'Mobile Money':
        return 'mobile_money';
      case 'Bank Transfer':
        return 'bank_transfer';
      case 'Debit Card':
        return 'debit_card';
      case 'Credit Card':
        return 'credit_card';
      default:
        return 'unknown';
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _selectQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
  }

  String _formatAmount(double amount) {
    return '₵${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.textPrimaryColor,
          ),
        ),
        title: Text(
          'Add Money',
          style: TextStyle(
            color: context.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _userData == null || _walletData == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading wallet data...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Balance Card
                    _buildCurrentBalanceCard(context),
                    
                    const SizedBox(height: 32),
                    
                    // Amount Input Section
                    _buildAmountInputSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Amount Selection
                    _buildQuickAmountSection(context),
                    
                    const SizedBox(height: 32),
                    
                    // Payment Method Selection
                    _buildPaymentMethodSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Optional Note
                    _buildNoteSection(context),
                    
                    const SizedBox(height: 40),
                    
                    // Add Money Button
                    _buildAddMoneyButton(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard(BuildContext context) {
    final balance = (_walletData?['balance'] ?? 0).toDouble();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF059669),
            Color(0xFF10B981),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: context.textSecondaryColor,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20, right: 12),
                child: Text(
                  '₵',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _quickAmounts.map((amount) {
            return GestureDetector(
              onTap: () => _selectQuickAmount(amount),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _amountController.text == amount.toStringAsFixed(0)
                        ? const Color(0xFF3B82F6)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '₵${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            dropdownColor: context.cardBackgroundColor,
            items: _paymentMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(method),
                      color: const Color(0xFF3B82F6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      method,
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Mobile Money':
        return Icons.phone_android;
      case 'Bank Transfer':
        return Icons.account_balance;
      case 'Credit Card':
        return Icons.credit_card;
      case 'Debit Card':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  Widget _buildNoteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Note (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(
              color: context.textPrimaryColor,
            ),
            decoration: InputDecoration(
              hintText: 'Enter a note for this transaction...',
              hintStyle: TextStyle(
                color: context.textSecondaryColor,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoneyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addMoney,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Add Money',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}