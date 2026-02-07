import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/core/utils/validators.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);
    await authController.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (!authState.isLoading) {
        // Use synchronous FirebaseAuth.currentUser instead of the stream
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          // Fetch user role from Firestore
          final userRepo = ref.read(userRepositoryProvider);
          final userModel = await userRepo.getUserById(firebaseUser.uid);
          if (mounted) {
            if (userModel?.isAdmin == true) {
              context.go(RouteConstants.admin);
            } else {
              context.go(RouteConstants.books);
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or title
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _handleSignIn(),
                  ),
                  const SizedBox(height: 24),

                  // Sign in button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSignIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go(RouteConstants.signUp),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
