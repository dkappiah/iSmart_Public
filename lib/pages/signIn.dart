import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // App Logo and Header
                  _buildHeader(),
                  const SizedBox(height: 60),
                  
                  // Welcome Text
                  _buildWelcomeText(),
                  const SizedBox(height: 40),
                  
                  // Login Form
                  _buildLoginForm(),
                  const SizedBox(height: 24),
                  
                  // Remember Me & Forgot Password
                  _buildRememberAndForgot(),
                  const SizedBox(height: 32),
                  
                  // Login Button
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  
                  // Or Divider
                  //_buildOrDivider(),
                  const SizedBox(height: 24),
                  
                          
                  // Sign Up Link
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'DigiPurse',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account to continue',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hintText: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        
        // Password Field
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Enter your password',
          obscureText: !_isPasswordVisible,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[500],
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[500], size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'Remember me',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Handle forgot password
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Bypass validation for now - direct to homepage
          Navigator.pushReplacementNamed(context, '/home');
          
          /*
          // Actual validation code (commented for now)
          if (_formKey.currentState!.validate()) {
            // Handle login
            Navigator.pushReplacementNamed(context, '/home');
          }
          */
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}