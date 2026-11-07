
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';

const Color authNavy = Color(0xFF202B45);
const Color authCoral = Color(0xFFF07861);
const Color authIvory = Color(0xFFFAF8F4);

class AuthScreen extends StatefulWidget {
  final String role;

  const AuthScreen({
    super.key,
    required this.role,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text.trim();
      final role = widget.role.toLowerCase();

      final accountKey = 'account_${role}_$email';

      final savedAccount = prefs.getString(accountKey);

      if (isLogin) {
        // LOGIN

        if (savedAccount == null) {
          showMessage('No account found. Please sign up first.');
          return;
        }

        final account = jsonDecode(savedAccount);

        if (account['password'] != password) {
          showMessage('Incorrect password. Please try again.');
          return;
        }

        if (!mounted) return;

        // Navigate to the correct dashboard.
        if (role == 'attendee') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AttendeeDashboard(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OrganizerDashboard(),
            ),
          );
        }
      } else {
        // SIGN UP

        if (savedAccount != null) {
          showMessage('This email is already registered.');
          return;
        }

        final newAccount = {
          'name': nameController.text.trim(),
          'email': email,
          'password': password,
          'role': role,
        };

        await prefs.setString(
          accountKey,
          jsonEncode(newAccount),
        );

        if (!mounted) return;

        setState(() {
          isLogin = true;
          passwordController.clear();
        });

        showMessage('Account created successfully! Please login.');
      }
    } catch (e) {
      if (mounted) {
        showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: authNavy),
      filled: true,
      fillColor: authIvory,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: authCoral,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: authIvory,
      appBar: AppBar(
        title: const Text(
          'EventHub',
          style: TextStyle(
            color: authNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: authIvory,
        elevation: 0,
        foregroundColor: authNavy,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Icon(
                          widget.role.toLowerCase() == 'attendee'
                              ? Icons.event_available
                              : Icons.event_note,
                          size: 50,
                          color: authCoral,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: Text(
                          isLogin
                              ? '${widget.role} Login'
                              : 'Create ${widget.role} Account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: authNavy,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          isLogin
                              ? 'Welcome back! Login to continue.'
                              : 'Create an account to get started.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // NAME FIELD - Only for Sign Up
                      if (!isLogin) ...[
                        TextFormField(
                          controller: nameController,
                          decoration: inputDecoration(
                            'Full Name',
                            Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                      ],

                      // EMAIL FIELD
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: inputDecoration(
                          'Email Address',
                          Icons.email_outlined,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your email';
                          }

                          final emailPattern =
                              RegExp(r'^[^@]+@[^@]+\.[^@]+$');

                          if (!emailPattern.hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD FIELD
                      TextFormField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: inputDecoration(
                          'Password',
                          Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: authNavy,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
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

                      const SizedBox(height: 25),

                      // LOGIN / SIGN UP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: authCoral,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isLogin
                                      ? 'Login'
                                      : 'Create Account',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // SWITCH LOGIN / SIGN UP
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                              passwordController.clear();
                            });
                          },
                          child: Text(
                            isLogin
                                ? "Don't have an account? Sign Up"
                                : 'Already have an account? Login',
                            style: const TextStyle(
                              color: authNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
