import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mobile_digital_wallet/providers/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransferFundsPage extends StatefulWidget {
  const TransferFundsPage({Key? key}) : super(key: key);

  @override
  State<TransferFundsPage> createState() => _TransferFundsPageState();
}

class _TransferFundsPageState extends State<TransferFundsPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  bool _isSearching = false;
  String _recipientSearchType = 'Username';
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _walletData;
  Map<String, dynamic>? _selectedRecipient;
  List<Map<String, dynamic>> _searchResults = [];
  
  final List<String> _searchTypes = ['Username', 'Email'];
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

      // Fetch user data
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

      // Fetch wallet data
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
          _showSnackBar('Wallet not found. Please contact support.', Colors.red);
          return;
        }
      } else {
        _walletData = walletResponse;
      }
      
      setState(() {});
      
    } catch (error) {
      _showSnackBar('Error loading user data: ${error.toString()}', Colors.red);
    }
  }

  Future<void> _searchRecipients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _selectedRecipient = null;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final currentUserId = _userData!['id'];
      List<Map<String, dynamic>> results = [];

      if (_recipientSearchType == 'Username') {
        final response = await _supabase
            .from('users')
            .select('id, username, email, first_name, last_name')
            .ilike('username', '%$query%')
            .neq('id', currentUserId)
            .limit(5);
        results = List<Map<String, dynamic>>.from(response);
      } else {
        final response = await _supabase
            .from('users')
            .select('id, username, email, first_name, last_name')
            .ilike('email', '%$query%')
            .neq('id', currentUserId)
            .limit(5);
        results = List<Map<String, dynamic>>.from(response);
      }

      setState(() {
        _searchResults = results;
        _selectedRecipient = null;
      });

    } catch (error) {
      _showSnackBar('Error searching for recipients: ${error.toString()}', Colors.red);
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _transferFunds() async {
    // Validation
    if (_selectedRecipient == null) {
      _showSnackBar('Please select a recipient', Colors.red);
      return;
    }

    if (_amountController.text.isEmpty) {
      _showSnackBar('Please enter an amount', Colors.red);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', Colors.red);
      return;
    }

    // Check balance
    final currentBalance = (_walletData!['balance'] ?? 0).toDouble();
    if (amount > currentBalance) {
      _showSnackBar('Insufficient balance. Available: ₵${currentBalance.toStringAsFixed(2)}', Colors.red);
      return;
    }

    // Check if user and wallet data are loaded
    if (_userData == null || _walletData == null) {
      _showSnackBar('User or wallet data not loaded. Please try again.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final senderWalletId = _walletData!['id'];
      final senderId = _userData!['id'];
      final senderAuthId = _supabase.auth.currentUser!.id;
      final recipientId = _selectedRecipient!['id'];

      // Get recipient's wallet
      final recipientWalletResponse = await _supabase
          .from('wallets')
          .select('*')
          .eq('user_id', recipientId)
          .maybeSingle();

      if (recipientWalletResponse == null) {
        _showSnackBar('Recipient wallet not found. Please contact support.', Colors.red);
        return;
      }

      final recipientWalletId = recipientWalletResponse['id'];
      final recipientCurrentBalance = (recipientWalletResponse['balance'] ?? 0).toDouble();

      final now = DateTime.now().toUtc();
      final referenceNumber = 'TRF_${now.millisecondsSinceEpoch}';

      // Start transaction - Update sender's wallet balance
      final newSenderBalance = currentBalance - amount;
      
      try {
        await _supabase
            .from('wallets')
            .update({
              'balance': newSenderBalance,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', senderWalletId);
      } catch (error) {
        throw Exception('Failed to update sender wallet: $error');
      }

      // Update recipient's wallet balance
      final newRecipientBalance = recipientCurrentBalance + amount;
      
      try {
        await _supabase
            .from('wallets')
            .update({
              'balance': newRecipientBalance,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', recipientWalletId);
      } catch (error) {
        // Rollback sender's wallet
        try {
          await _supabase
              .from('wallets')
              .update({
                'balance': currentBalance,
                'updated_at': now.toIso8601String(),
              })
              .eq('id', senderWalletId);
        } catch (rollbackError) {
          // Critical error - log this in production
        }
        throw Exception('Failed to update recipient wallet: $error');
      }

      // Create sender transaction record
      final senderTransactionData = {
        'user_id': senderAuthId,
        'transaction_type': 'transfer_out',
        'amount': -amount, // Negative for outgoing
        'status': 'completed',
        'description': _noteController.text.isEmpty 
            ? 'Transfer to ${_selectedRecipient!['username'] ?? _selectedRecipient!['email']}'
            : _noteController.text,
        'reference_number': referenceNumber,
        'source_type': 'internal_transfer',
        'created_at': now.toIso8601String(),
        'completed_at': now.toIso8601String(),
        'metadata': {
          'recipient_id': recipientId,
          'recipient_username': _selectedRecipient!['username'],
          'recipient_email': _selectedRecipient!['email'],
          'transfer_type': 'sent',
          'wallet_id': senderWalletId,
          'original_balance': currentBalance,
          'new_balance': newSenderBalance,
        },
      };

      // Create recipient transaction record
      final recipientTransactionData = {
        'user_id': recipientId, // Use recipient's user_id, not auth_user_id
        'transaction_type': 'transfer_in',
        'amount': amount, // Positive for incoming
        'status': 'completed',
        'description': 'Transfer from ${_userData!['username'] ?? _userData!['email']}' +
            (_noteController.text.isEmpty ? '' : ' - ${_noteController.text}'),
        'reference_number': referenceNumber,
        'source_type': 'internal_transfer',
        'created_at': now.toIso8601String(),
        'completed_at': now.toIso8601String(),
        'metadata': {
          'sender_id': senderId,
          'sender_username': _userData!['username'],
          'sender_email': _userData!['email'],
          'transfer_type': 'received',
          'wallet_id': recipientWalletId,
          'original_balance': recipientCurrentBalance,
          'new_balance': newRecipientBalance,
        },
      };

      try {
        // Insert both transaction records
        await _supabase.from('transactions').insert([
          senderTransactionData,
          recipientTransactionData,
        ]);
      } catch (transactionError) {
        // Rollback both wallets
        try {
          await _supabase.from('wallets').update({
            'balance': currentBalance,
            'updated_at': now.toIso8601String(),
          }).eq('id', senderWalletId);
          
          await _supabase.from('wallets').update({
            'balance': recipientCurrentBalance,
            'updated_at': now.toIso8601String(),
          }).eq('id', recipientWalletId);
        } catch (rollbackError) {
          // Critical error - log this in production
        }
        
        throw Exception('Failed to create transaction records: $transactionError');
      }

      // Update local wallet data
      _walletData!['balance'] = newSenderBalance;

      // Show success message
      _showSnackBar(
        'Successfully transferred ₵${amount.toStringAsFixed(2)} to ${_selectedRecipient!['username'] ?? _selectedRecipient!['email']}!',
        Colors.green,
      );

      // Clear form
      _amountController.clear();
      _noteController.clear();
      _recipientController.clear();
      setState(() {
        _selectedRecipient = null;
        _searchResults = [];
      });

      // Navigate back with success result
      Navigator.of(context).pop(true);

    } catch (error) {
      String errorMessage = 'Failed to transfer funds. Please try again.';
      
      if (error is PostgrestException) {
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

  void _selectRecipient(Map<String, dynamic> recipient) {
    setState(() {
      _selectedRecipient = recipient;
      _recipientController.text = recipient['username'] ?? recipient['email'];
      _searchResults = [];
    });
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
          'Transfer Funds',
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
                    
                    // Recipient Selection Section
                    _buildRecipientSelectionSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Amount Input Section
                    _buildAmountInputSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Amount Selection
                    _buildQuickAmountSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Optional Note
                    _buildNoteSection(context),
                    
                    const SizedBox(height: 40),
                    
                    // Transfer Button
                    _buildTransferButton(context),
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
            'Available Balance',
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

  Widget _buildRecipientSelectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Send To',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _recipientSearchType,
                  isDense: true,
                  items: _searchTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recipientSearchType = value!;
                      _recipientController.clear();
                      _searchResults = [];
                      _selectedRecipient = null;
                    });
                  },
                ),
              ),
            ),
          ],
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
          child: Column(
            children: [
              TextField(
                controller: _recipientController,
                onChanged: _searchRecipients,
                style: TextStyle(
                  fontSize: 16,
                  color: context.textPrimaryColor,
                ),
                decoration: InputDecoration(
                  hintText: _recipientSearchType == 'Username' 
                      ? 'Enter username...' 
                      : 'Enter email address...',
                  hintStyle: TextStyle(
                    color: context.textSecondaryColor,
                  ),
                  prefixIcon: Icon(
                    _recipientSearchType == 'Username' 
                        ? Icons.person_search 
                        : Icons.email_outlined,
                    color: const Color(0xFF3B82F6),
                    size: 20,
                  ),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _selectedRecipient != null
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty) ...[
                const Divider(height: 1),
                ..._searchResults.map((recipient) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF3B82F6),
                      child: Text(
                        (recipient['first_name']?[0] ?? recipient['username']?[0] ?? recipient['email'][0]).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      recipient['username'] ?? 'No username',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    subtitle: Text(
                      recipient['email'] ?? '',
                      style: TextStyle(
                        color: context.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => _selectRecipient(recipient),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ],
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
              hintText: 'Enter a note for this transfer...',
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

  Widget _buildTransferButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _transferFunds,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFEF4444).withOpacity(0.3),
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
                'Transfer Funds',
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
    _recipientController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}