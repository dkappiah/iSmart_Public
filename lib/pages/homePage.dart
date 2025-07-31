import 'package:flutter/material.dart';
import 'package:mini_mobile_digital_wallet/pages/profilePage.dart';
import 'package:mini_mobile_digital_wallet/pages/addMoney.dart';
import 'package:mini_mobile_digital_wallet/pages/transactionPage.dart';
import 'package:mini_mobile_digital_wallet/pages/transferFunds.dart';
import 'package:mini_mobile_digital_wallet/widget/navBar.dart';
import 'package:mini_mobile_digital_wallet/providers/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // List of pages for navigation - ensure only 3 pages
  final List<Widget> _pages = [
    const _HomeContent(),     // index 0 - Home
    const TransactionsPage(), // index 1 - Transactions  
    const ProfilePage(),      // index 2 - Profile
  ];

  void _onNavTap(int index) {
    // Add bounds checking to prevent RangeError
    if (index < 0 || index >= _pages.length) {
      print('Invalid navigation index: $index, max allowed: ${_pages.length - 1}');
      return;
    }
    
    print('Navigation: switching from $_currentIndex to $index');
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({Key? key}) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _isBalanceVisible = true;
  bool _isLoading = true;
  bool _isLoadingTransactions = false;
  String? _transactionsError;
  
  // User and wallet data
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _walletData;
  List<Transaction> _recentTransactions = [];
  
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        // Handle unauthenticated user
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      print('Current user ID: ${user.id}');

      // Fetch user data
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('auth_user_id', user.id)
          .single();

      print('User response: $userResponse');
      
      if (mounted) {
        setState(() {
          _userData = userResponse;
        });
      }
      
      if (_userData != null) {
        // Fetch wallet data
        try {
          final walletResponse = await _supabase
              .from('wallets')
              .select('*')
              .eq('user_id', _userData!['id'])
              .single();
              
          print('Wallet response: $walletResponse');
          if (mounted) {
            setState(() {
              _walletData = walletResponse;
            });
          }
        } catch (walletError) {
          print('Wallet error: $walletError');
          // If no wallet exists, create one
          if (walletError.toString().contains('No rows found')) {
            await _createWalletForUser();
          } else {
            print('Error fetching wallet: $walletError');
          }
        }
        
        // Fetch recent transactions
        await _loadRecentTransactions();
      }
      
    } catch (error) {
      print('Error loading user data: $error');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createWalletForUser() async {
    try {
      print('Creating wallet for user: ${_userData!['id']}');
      final walletResponse = await _supabase
          .from('wallets')
          .insert({
            'user_id': _userData!['id'],
            'balance': 0.00,
            'currency': 'GHS',
          })
          .select()
          .single();
          
      if (mounted) {
        setState(() {
          _walletData = walletResponse;
        });
      }
      print('Wallet created successfully: $walletResponse');
    } catch (error) {
      print('Error creating wallet: $error');
    }
  }

  Future<void> _loadRecentTransactions() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoadingTransactions = true;
        _transactionsError = null;
      });

      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _transactionsError = 'User not authenticated';
            _isLoadingTransactions = false;
          });
        }
        return;
      }

      final response = await _supabase
          .from('transactions')
          .select('''
            id,
            user_id,
            transaction_type,
            amount,
            status,
            description,
            recipient_email,
            source_type,
            created_at,
            completed_at,
            metadata
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(3);

      if (response != null && mounted) {
        final List<Transaction> transactions = (response as List)
            .map((json) => Transaction.fromSupabaseJson(json))
            .toList();

        setState(() {
          _recentTransactions = transactions;
          _isLoadingTransactions = false;
        });
      }
    } catch (error) {
      print('Error loading recent transactions: $error');
      if (mounted) {
        setState(() {
          _transactionsError = error.toString();
          _isLoadingTransactions = false;
        });
      }
    }
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatAmount(double amount, {bool hideDecimals = false}) {
    final currency = _walletData?['currency'] ?? 'GHS';
    final symbol = currency == 'GHS' ? '₵' : currency;
    
    if (hideDecimals) {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header Section
                _buildHeader(context),
                
                // Balance Card
                _buildBalanceCard(context),
                            
                // Recent Transactions
                _buildRecentTransactions(context),
                
                const SizedBox(height: 100), // Space for bottom navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userData?['full_name']?.toString() ?? 'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  themeProvider.toggleTheme();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    size: 24,
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final balance = _walletData?['balance']?.toDouble() ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: _toggleBalanceVisibility,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isBalanceVisible ? _formatAmount(balance) : '₵••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, Icons.add_circle_outline, 'Add Funds', Colors.white),
              _buildActionButton(context, Icons.send_outlined, 'Transfer Funds', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        // Handle action button taps
        switch (label) {
          case 'Add Funds':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMoneyPage()),
            );
            break;
          case 'Transfer Funds':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransferFundsPage()),
            );
            break;
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Loading state
          if (_isLoadingTransactions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          
          // Error state
          else if (_transactionsError != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to load transactions',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          
          // Empty state
          else if (_recentTransactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: context.textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No recent transactions',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your transaction history will appear here',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textTertiaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          
          // Transactions list
          else
            Column(
              children: _recentTransactions.map((transaction) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Transaction Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: transaction.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            transaction.iconData,
                            color: transaction.color,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Transaction Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildCompactStatusBadge(transaction.status),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              transaction.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Amount and Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${transaction.type == TransactionType.add ? '+' : ''}₵${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: transaction.type == TransactionType.add 
                                  ? Colors.green 
                                  : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCompactDate(transaction.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textTertiaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Helper method for compact status badge
  Widget _buildCompactStatusBadge(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    } else {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
  }

  // Helper method for compact date formatting
  String _formatCompactDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Transaction Model and Enums
class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final IconData iconData;
  final Color color;
  final String? recipientEmail;
  final String? sourceType;

  Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.iconData,
    required this.color,
    this.recipientEmail,
    this.sourceType,
  });

  factory Transaction.fromSupabaseJson(Map<String, dynamic> json) {
    final transactionType = json['transaction_type'] == 'add' 
        ? TransactionType.add 
        : TransactionType.transfer;
    
    final status = json['status'] == 'completed' 
        ? TransactionStatus.completed 
        : TransactionStatus.failed;

    // Determine icon and color based on type
    IconData iconData;
    Color color;
    String title;
    String subtitle;

    if (transactionType == TransactionType.add) {
      iconData = Icons.add_circle;
      color = Colors.green;
      title = 'Money Added';
      subtitle = json['source_type'] ?? 'External Source';
    } else {
      iconData = Icons.send;
      color = Colors.blue;
      title = 'Transfer Sent';
      subtitle = json['recipient_email'] ?? 'Unknown Recipient';
    }

    return Transaction(
      id: json['id'],
      title: json['description'] ?? title,
      subtitle: subtitle,
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['created_at']),
      type: transactionType,
      status: status,
      iconData: iconData,
      color: color,
      recipientEmail: json['recipient_email'],
      sourceType: json['source_type'],
    );
  }
}

enum TransactionType {
  add,
  transfer,
}

enum TransactionStatus {
  completed,
  failed,
}