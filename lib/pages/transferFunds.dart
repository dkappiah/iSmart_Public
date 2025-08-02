import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mobile_digital_wallet/providers/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mini_mobile_digital_wallet/services/transferService.dart';

class TransferFundsPage extends StatefulWidget {
  const TransferFundsPage({Key? key}) : super(key: key);

  @override
  State<TransferFundsPage> createState() => _TransferFundsPageState();
}

class _TransferFundsPageState extends State<TransferFundsPage>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TransferService _transferService = TransferService(client: Supabase.instance.client);
  
  bool _isLoading = false;
  bool _isTransferring = false;
  bool _obscurePin = true;
  bool _isPinFocused = false;
  int _pinAttempts = 0;
  bool _isAccountLocked = false;
  DateTime? _lockoutStartTime;
  
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _walletData;
  
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;
  
  final List<double> _quickAmounts = [10.0, 25.0, 50.0, 100.0, 200.0, 500.0];
  final int _maxPinAttempts = 3;
  final Duration _lockoutDuration = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Initialize animations
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Check lockout status periodically
    _checkLockoutStatus();
  }

  void _checkLockoutStatus() {
    if (_isAccountLocked && _lockoutStartTime != null) {
      final elapsed = DateTime.now().difference(_lockoutStartTime!);
      if (elapsed >= _lockoutDuration) {
        setState(() {
          _isAccountLocked = false;
          _pinAttempts = 0;
          _lockoutStartTime = null;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final data = await _transferService.loadUserData(user.id);
      if (data == null) {
        _showSnackBar('User profile or wallet not found.', Colors.red);
        return;
      }

      setState(() {
        _userData = data['user'];
        _walletData = data['wallet'];
      });
      
    } catch (error) {
      _showSnackBar('Error loading user data: ${error.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processTransfer() async {
    // Check if account is locked
    _checkLockoutStatus();
    if (_isAccountLocked) {
      final remainingTime = _lockoutDuration - DateTime.now().difference(_lockoutStartTime!);
      final minutes = remainingTime.inMinutes;
      final seconds = remainingTime.inSeconds % 60;
      _showSnackBar(
        'Account locked. Try again in ${minutes}m ${seconds}s', 
        Colors.red
      );
      return;
    }

    // Prevent multiple simultaneous transfers
    if (_isTransferring) {
      _showSnackBar('Transfer already in progress...', Colors.orange);
      return;
    }

    final recipientInput = _recipientController.text.trim();
    final amountText = _amountController.text.trim();
    final note = _noteController.text.trim();
    final pin = _pinController.text.trim();

    // Basic validation
    if (recipientInput.isEmpty) {
      _showSnackBar('Please enter a username or email', Colors.red);
      return;
    }

    if (amountText.isEmpty) {
      _showSnackBar('Please enter an amount', Colors.red);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', Colors.red);
      return;
    }

    // Check current balance
    final currentBalance = (_walletData?['balance'] ?? 0).toDouble();
    if (amount > currentBalance) {
      _showSnackBar('Insufficient balance. Available: ₵${currentBalance.toStringAsFixed(2)}', Colors.red);
      return;
    }

    // PIN validation
    if (pin.isEmpty) {
      _showSnackBar('Please enter your transaction PIN', Colors.red);
      _shakePinField();
      return;
    }

    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showSnackBar('PIN must be exactly 4 digits', Colors.red);
      _shakePinField();
      return;
    }

    setState(() => _isTransferring = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showSnackBar('Session expired. Please login again.', Colors.red);
        return;
      }

      // Verify PIN
      final pinValid = await _transferService.verifyTransactionPin(user.id, pin);
      
      if (!pinValid) {
        _pinAttempts++;
        _shakePinField();
        
        if (_pinAttempts >= _maxPinAttempts) {
          setState(() {
            _isAccountLocked = true;
            _lockoutStartTime = DateTime.now();
          });
          _showSnackBar(
            'Too many failed PIN attempts. Account locked for ${_lockoutDuration.inMinutes} minutes.', 
            Colors.red
          );
        } else {
          final remaining = _maxPinAttempts - _pinAttempts;
          _showSnackBar(
            'Incorrect PIN. $remaining attempt${remaining != 1 ? 's' : ''} remaining.', 
            Colors.red
          );
        }
        
        _pinController.clear();
        setState(() => _isTransferring = false);
        return;
      }

      // Reset PIN attempts on successful verification
      setState(() => _pinAttempts = 0);

      // Process transfer
      final result = await _transferService.processTransfer(
        recipientIdentifier: recipientInput,
        amount: amount,
        note: note,
        currentUserId: user.id,
      );

      if (result['success']) {
        // Show success message with reference number
        final refNumber = result['reference_number'] ?? '';
        _showSnackBar(
          '${result['message']}\nRef: $refNumber', 
          Colors.green
        );

        // Refresh user data to get updated balance
        await _loadUserData();

        // Clear form
        _clearForm();
      } else {
        _showSnackBar(result['message'], Colors.red);
      }

    } catch (error) {
      _showSnackBar('An unexpected error occurred. Please try again.', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }

  void _shakePinField() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _clearForm() {
    _amountController.clear();
    _noteController.clear();
    _recipientController.clear();
    _pinController.clear();
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: Duration(seconds: color == Colors.green ? 6 : 4),
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

  String _getRemainingLockoutTime() {
    if (!_isAccountLocked || _lockoutStartTime == null) return '';
    
    final elapsed = DateTime.now().difference(_lockoutStartTime!);
    final remaining = _lockoutDuration - elapsed;
    
    if (remaining.isNegative) {
      // Lockout expired, update state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isAccountLocked = false;
          _pinAttempts = 0;
          _lockoutStartTime = null;
        });
      });
      return '';
    }
    
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes}m ${seconds}s';
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
        child: _isLoading
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
                    _buildCurrentBalanceCard(context),
                    const SizedBox(height: 32),
                    _buildRecipientInputSection(context),
                    const SizedBox(height: 24),
                    _buildAmountInputSection(context),
                    const SizedBox(height: 24),
                    _buildQuickAmountSection(context),
                    const SizedBox(height: 24),
                    _buildNoteSection(context),
                    const SizedBox(height: 24),
                    _buildEnhancedPinSection(context),
                    const SizedBox(height: 40),
                    _buildTransferButton(context),
                  ],
                ),
              ),
      ),
    );
  }

  // ... (Keep all the existing build methods unchanged)
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

  Widget _buildRecipientInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send To',
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
            controller: _recipientController,
            decoration: InputDecoration(
              hintText: 'Enter username or email',
              hintStyle: TextStyle(
                color: context.textSecondaryColor,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            'Enter the exact username or email of the recipient',
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 12,
            ),
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

  Widget _buildEnhancedPinSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.security,
              color: _isAccountLocked ? Colors.red : const Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Transaction PIN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
            if (_isAccountLocked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'LOCKED ${_getRemainingLockoutTime()}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isPinFocused ? _pulseAnimation.value : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isAccountLocked
                              ? Colors.red
                              : _isPinFocused
                                  ? const Color(0xFFEF4444)
                                  : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isAccountLocked
                                ? Colors.red.withOpacity(0.2)
                                : _isPinFocused
                                    ? const Color(0xFFEF4444).withOpacity(0.2)
                                    : context.shadowColor,
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            _isPinFocused = hasFocus;
                          });
                        },
                        child: TextField(
                          controller: _pinController,
                          enabled: !_isAccountLocked,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _isAccountLocked
                                ? Colors.grey
                                : context.textPrimaryColor,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••',
                            hintStyle: TextStyle(
                              color: context.textSecondaryColor,
                              letterSpacing: 8,
                            ),
                            prefixIcon: Icon(
                              _isAccountLocked ? Icons.lock : Icons.lock_outline,
                              color: _isAccountLocked
                                  ? Colors.red
                                  : const Color(0xFFEF4444),
                              size: 20,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_pinAttempts > 0 && !_isAccountLocked)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_maxPinAttempts - _pinAttempts}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  onPressed: _isAccountLocked
                                      ? null
                                      : () {
                                          setState(() {
                                            _obscurePin = !_obscurePin;
                                          });
                                        },
                                  icon: Icon(
                                    _obscurePin
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: _isAccountLocked
                                        ? Colors.grey
                                        : context.textSecondaryColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            counterText: '', // Hide character counter
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(
            children: [
              Icon(
                _isAccountLocked
                    ? Icons.warning
                    : Icons.info_outline,
                size: 12,
                color: _isAccountLocked
                    ? Colors.red
                    : context.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _isAccountLocked
                      ? 'Account locked due to multiple failed PIN attempts'
                      : 'Enter your 4-digit transaction PIN to authorize transfer',
                  style: TextStyle(
                    color: _isAccountLocked
                        ? Colors.red
                        : context.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
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
        onPressed: (_isTransferring || _isAccountLocked) ? null : _processTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAccountLocked
              ? Colors.grey
              : const Color(0xFFEF4444),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _isAccountLocked ? 0 : 8,
          shadowColor: const Color(0xFFEF4444).withOpacity(0.3),
        ),
        child: _isTransferring
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isAccountLocked 
                    ? 'Account Locked (${_getRemainingLockoutTime()})' 
                    : 'Send Money',
                style: const TextStyle(
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
    _pinController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}