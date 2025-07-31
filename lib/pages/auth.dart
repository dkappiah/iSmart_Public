// auth.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mobile_digital_wallet/services/authService.dart';

class AuthPage extends StatefulWidget {
  final bool isSignIn;
  const AuthPage({Key? key, this.isSignIn = true}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Common controllers and variables
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Sign-up specific controllers and variables
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _rememberMe = false;

  // Get auth service instance
  final AuthService _authService = AuthServiceManager.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _telephoneController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isSignIn) ...[
                    const SizedBox(height: 40),
                    _buildAppLogoHeader(),
                    const SizedBox(height: 60),
                    _buildWelcomeText(
                        "Welcome back", "Sign in to your account to continue"),
                    const SizedBox(height: 40),
                    _buildLoginForm(),
                    const SizedBox(height: 24),
                    _buildRememberAndForgot(),
                    const SizedBox(height: 32),
                    _buildAuthButton("Sign In", _handleLogin),
                    const SizedBox(height: 24),
                    _buildAuthLink(
                        "Don't have an account? ", "Sign Up", false),
                  ] else ...[
                    const SizedBox(height: 20),
                    _buildBackHeader("Create Account"),
                    const SizedBox(height: 40),
                    _buildWelcomeText("Get started",
                        "Create your account and start managing your finances"),
                    const SizedBox(height: 40),
                    _buildSignUpForm(),
                    const SizedBox(height: 24),
                    _buildTermsAndConditions(),
                    const SizedBox(height: 32),
                    _buildAuthButton("Create Account", _handleSignUp),
                    const SizedBox(height: 24),
                    _buildAuthLink(
                        "Already have an account? ", "Sign In", true),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Common Widgets
  Widget _buildWelcomeText(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool enabled = true,
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
          inputFormatters: inputFormatters,
          validator: validator,
          enabled: enabled && !_isLoading,
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
            fillColor: _isLoading ? Colors.grey[50] : const Color(0xFFF9FAFB),
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

  Widget _buildAuthButton(String text, VoidCallback onPressed) {
    final isEnabled = widget.isSignIn || _agreeToTerms;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled && !_isLoading
            ? [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isEnabled && !_isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildAuthLink(String prompt, String linkText, bool isSignIn) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prompt,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthPage(isSignIn: isSignIn),
                        ),
                      );
                    }
                  },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              linkText,
              style: const TextStyle(
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

  // Sign-in Specific Widgets
  Widget _buildAppLogoHeader() {
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

  Widget _buildLoginForm() {
    return Column(
      children: [
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

  // Sign-up Specific Widgets
  Widget _buildBackHeader(String title) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Replace pop with pushReplacement
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthPage(isSignIn: true),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hintText: 'Enter your full name',
          keyboardType: TextInputType.name,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          hintText: 'Choose a unique username',
          keyboardType: TextInputType.text,
          prefixIcon: Icons.alternate_email_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
            LengthLimitingTextInputFormatter(20),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
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
        _buildTextField(
          controller: _telephoneController,
          label: 'Telephone',
          hintText: 'Enter your telephone number (e.g., 233597456982)',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your telephone number';
            }
            if (value.length < 10) {
              return 'Please enter a valid telephone number';
            }
            if (!RegExp(r'^[0-9]{10,12}$').hasMatch(value)) {
              return 'Please enter a valid telephone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Create a strong password',
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
            if (value.length < 4) {
              return 'Password must be at least 4 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, and number';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Confirm your password',
          obscureText: !_isConfirmPasswordVisible,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[500],
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _pinController,
          label: 'PIN',
          hintText: 'Enter 4-digit PIN',
          obscureText: true,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.pin_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your PIN';
            }
            if (value.length != 4) {
              return 'PIN must be exactly 4 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 0.9,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
            activeColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Auth Handlers
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (result.success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        String errorMessage = result.message ?? 'Unable to sign in';
        // Convert technical error messages to user-friendly ones
        switch (errorMessage.toLowerCase()) {
          case 'invalid credentials':
            errorMessage = 'The email or password you entered is incorrect';
            break;
          case 'user not found':
            errorMessage = 'No account found with this email';
            break;
          case 'invalid email':
            errorMessage = 'Please enter a valid email address';
            break;
          default:
            errorMessage = 'Unable to sign in. Please check your credentials and try again';
        }
        _showSnackBar(
          message: errorMessage,
          isSuccess: false,
        );
      }
    } catch (e) {
      _showSnackBar(
        message: 'We\'re having trouble connecting to our servers. Please check your internet connection and try again',
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        password: _passwordController.text,
        pin: _pinController.text,
        // TS: Add username parameter to AuthService.signUp method
        username: _usernameController.text.trim(),
      );

      if (result.success) {
        _showSnackBar(
          message: 'Your account has been created successfully! Please check your email to verify your account.',
          isSuccess: true,
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthPage(isSignIn: true),
            ),
          );
        }
      } else {
        String errorMessage = result.message ?? 'Unable to create account';
        // Convert technical error messages to user-friendly ones
        switch (errorMessage.toLowerCase()) {
          case 'email already exists':
            errorMessage = 'An account with this email already exists';
            break;
          case 'username already exists':
            errorMessage = 'This username is already taken. Please choose another one';
            break;
          case 'telephone already exists':
            errorMessage = 'An account with this phone number already exists';
            break;
          case 'weak password':
            errorMessage = 'Please choose a stronger password. Include uppercase, lowercase, numbers, and special characters';
            break;
          case 'invalid phone':
            errorMessage = 'Please enter a valid phone number starting with your country code';
            break;
          default:
            errorMessage = 'Unable to create your account. Please try again or contact support if the problem persists';
        }
        _showSnackBar(
          message: errorMessage,
          isSuccess: false,
        );
      }
    } catch (e) {
      _showSnackBar(
        message: 'We\'re having trouble connecting to our servers. Please check your internet connection and try again later',
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar({
    required String message,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSuccess ? 'Success' : 'Error',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 4,
        action: isSuccess
            ? SnackBarAction(
                label: 'Sign In',
                textColor: Colors.white,
                onPressed: () {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(isSignIn: true),
                      ),
                    );
                  }
                },
              )
            : null,
      ),
    );
  }
}