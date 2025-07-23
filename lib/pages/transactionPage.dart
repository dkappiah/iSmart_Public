import 'package:flutter/material.dart';
import 'package:mini_mobile_digital_wallet/widget/navBar.dart';
import 'package:mini_mobile_digital_wallet/providers/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _currentIndex = 2;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }


  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // just to ensure the user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      print('Loading transactions for user: ${user.id}');

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
          .order('created_at', ascending: false);

      print('Response from Supabase: $response');

      if (response == null) {
        setState(() {
          _error = 'No data received from server';
          _isLoading = false;
        });
        return;
      }

      final List<Transaction> transactions = (response as List)
          .map((json) {
            print('Processing transaction: $json');
            return Transaction.fromSupabaseJson(json);
          })
          .toList();

      print('Loaded ${transactions.length} transactions');

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        _error = 'Failed to load transactions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTransactions() async {
    await _loadTransactions();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index != 2) {
      Navigator.pop(context);
    }
  }

  List<Transaction> get _filteredTransactions {
    List<Transaction> filtered = _transactions;
    
    // Filter by type
    if (_selectedFilter != 'All') {
      filtered = filtered.where((transaction) {
        switch (_selectedFilter) {
          case 'Add':
            return transaction.type == TransactionType.add;
          case 'Transfer':
            return transaction.type == TransactionType.transfer;
          case 'Completed':
            return transaction.status == TransactionStatus.completed;
          case 'Failed':
            return transaction.status == TransactionStatus.failed;
          default:
            return true;
        }
      }).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (transaction.recipientEmail?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: _buildTransactionsList(),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _refreshTransactions();
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
                  ),
                ],
              ),
              child: Icon(
                Icons.refresh,
                size: 24,
                color: context.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: context.textSecondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: context.textPrimaryColor,
                fontSize: 14,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Icon(
                Icons.close,
                color: context.textSecondaryColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Add', 'Transfer', 'Completed', 'Failed'];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: context.cardBackgroundColor,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : context.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading transactions',
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: context.textTertiaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshTransactions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredTransactions = _filteredTransactions;
    
    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(
                fontSize: 14,
                color: context.textTertiaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          return _buildTransactionItem(transaction, index);
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                transaction.iconData,
                color: transaction.color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Transaction Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Status Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(transaction.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Amount and Type
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${transaction.type == TransactionType.add ? '+' : ''}₵${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: transaction.type == TransactionType.add ? Colors.green : Colors.blue,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                _buildTypeChip(transaction.type),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case TransactionStatus.completed:
        color = Colors.green;
        text = 'Done';
        break;
      case TransactionStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeChip(TransactionType type) {
    String text;
    Color color;
    
    switch (type) {
      case TransactionType.add:
        text = 'Add';
        color = Colors.green;
        break;
      case TransactionType.transfer:
        text = 'Transfer';
        color = Colors.blue;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour}:${minute} ${period}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Updated Transaction Model
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