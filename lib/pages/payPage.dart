import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/themeProvider.dart';
import '../widget/navBar.dart'; // Update import to match file name

class PayPage extends StatefulWidget {
  const PayPage({Key? key}) : super(key: key);

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  int _currentIndex = 1;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Already on Pay page
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/transactions');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: theme.isDarkMode 
          ? theme.darkTheme.scaffoldBackgroundColor 
          : theme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildQuickPayment(),
              _buildRecentPayments(),
              _buildPaymentServices(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(  // Update to use CustomBottomNavBar
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay Bills',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: theme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quick and secure payments',
            style: TextStyle(
              fontSize: 16,
              color: theme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPayment() {
    return GestureDetector(
      onTap: () {
        // Add navigation or action
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickPaymentItem(Icons.phone_android, 'Airtime', () {
              // Add airtime action
            }),
            _buildQuickPaymentItem(Icons.wifi, 'Data', () {
              // Add data action
            }),
            _buildQuickPaymentItem(Icons.flash_on, 'Power', () {
              // Add power action
            }),
            _buildQuickPaymentItem(Icons.water_drop, 'Water', () {
              // Add water action
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPaymentItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPayments() {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Payments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRecentPaymentItem('ECG', 'Last paid: Yesterday', Icons.flash_on, const Color(0xFFF59E0B)),
                _buildRecentPaymentItem('MTN', 'Last paid: 3 days ago', Icons.phone_android, const Color(0xFF10B981)),
                _buildRecentPaymentItem('GWCL', 'Last paid: Last week', Icons.water_drop, const Color(0xFF3B82F6)),
                _buildRecentPaymentItem('Vodafone', 'Last paid: 2 weeks ago', Icons.wifi, const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentItem(String title, String subtitle, IconData icon, Color color) {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode 
            ? theme.darkTheme.cardTheme.color 
            : theme.lightTheme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.isDarkMode 
                  ? theme.darkTheme.textTheme.bodyLarge!.color
                  : theme.lightTheme.textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.isDarkMode 
                  ? theme.darkTheme.textTheme.bodyMedium!.color
                  : theme.lightTheme.textTheme.bodyMedium!.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentServices() {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildServiceCard(
                'Buy Airtime',
                Icons.phone_android,
                const Color(0xFF10B981),
                'Top up any network',
              ),
              _buildServiceCard(
                'Buy Data',
                Icons.wifi,
                const Color(0xFF8B5CF6),
                'Purchase data bundles',
              ),
              _buildServiceCard(
                'Pay Electricity',
                Icons.flash_on,
                const Color(0xFFF59E0B),
                'Pay your ECG bill',
              ),
              _buildServiceCard(
                'Pay Water Bill',
                Icons.water_drop,
                const Color(0xFF3B82F6),
                'Pay your GWCL bill',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, String description) {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}