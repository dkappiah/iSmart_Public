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

  // List of pages for navigation
  final List<Widget> _pages = [
    const _HomeContent(), 
    const TransactionsPage(),
    const ProfilePage(),
  ];

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: _pages[_currentIndex],
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
  
  // User and wallet data
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _walletData;
  List<Map<String, dynamic>> _recentTransactions = [];
  
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
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      print('Current user ID: ${user.id}'); // Debug log

      // Fetch user data
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('auth_user_id', user.id)
          .single();

      print('User response: $userResponse'); // Debug log
      
      _userData = userResponse;
      print('User full name: ${_userData?['full_name']}'); // Debug log
      
      if (_userData != null) {
        // Fetch wallet data
        try {
          final walletResponse = await _supabase
              .from('wallets')
              .select('*')
              .eq('user_id', _userData!['id'])
              .single();
              
          print('Wallet response: $walletResponse'); // Debug log
          _walletData = walletResponse;
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
          
      _walletData = walletResponse;
      print('Wallet created successfully: $walletResponse');
    } catch (error) {
      print('Error creating wallet: $error');
    }
  }

  Future<void> _loadRecentTransactions() async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', _walletData!['id'])
          .order('created_at', ascending: false)
          .limit(3);
          
      if (response != null) {
        _recentTransactions = List<Map<String, dynamic>>.from(response);
      }
    } catch (error) {
      print('Error loading transactions: $error');
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

  String _formatTransactionDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today, ${TimeOfDay.fromDateTime(date).format(context)}';
    } else if (difference == 1) {
      return 'Yesterday, ${TimeOfDay.fromDateTime(date).format(context)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
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
              MaterialPageRoute(builder: (context) => AddMoneyPage()),
            );
            break;
          case 'Transfer Funds':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransferFundsPage()),
            );
            // Add your Send navigation here
            break;
          // case 'Pay Bills':
          //   // Add your Pay Bills navigation here
          //   break;
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
              )
            ],
          ),
          const SizedBox(height: 16),
          if (_recentTransactions.isEmpty)
            const Center(
              child: Text('No recent transactions'),
            )
          else
            ..._recentTransactions.map((transaction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionItem(
                  context,
                  _getTransactionInitial(transaction['title']),
                  transaction['title'] ?? 'Unknown',
                  transaction['category'] ?? 'General',
                  _formatTransactionDate(transaction['created_at']),
                  _formatAmount(transaction['amount']?.toDouble() ?? 0.0),
                  _getTransactionColor(transaction['type']),
                  transaction['is_recurring'] ?? false,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  String _getTransactionInitial(String? title) {
    if (title == null || title.isEmpty) return 'T';
    return title[0].toUpperCase();
  }

  Color _getTransactionColor(String? type) {
    switch (type) {
      case 'income':
        return const Color(0xFF059669);
      case 'expense':
        return const Color(0xFF10B981);
      case 'transfer':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String initial,
    String title,
    String subtitle,
    String date,
    String amount,
    Color color,
    bool isSubscription,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    if (isSubscription) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Recurring',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: amount.startsWith('-') ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}