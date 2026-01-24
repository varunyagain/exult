import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/core/constants/firebase_constants.dart';
import 'package:exult_flutter/core/utils/validators.dart';
import 'package:exult_flutter/domain/models/contact_model.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Create contact document
      final docRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.contactsCollection)
          .doc();

      final contact = Contact(
        id: docRef.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
        replied: false,
      );

      await docRef.set(contact.toJson());

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully! We\'ll get back to you soon.'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        _formKey.currentState!.reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exult'),
        actions: [
          TextButton(
            onPressed: () => context.go(RouteConstants.home),
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.howItWorks),
            child: const Text('How It Works'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.pricing),
            child: const Text('Pricing'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.contact),
            child: const Text('Contact'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => context.go(RouteConstants.signIn),
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Contact Us',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Have a question? We\'d love to hear from you.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Contact Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name Field
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                hintText: 'Enter your name',
                                prefixIcon: Icon(Icons.person_outlined),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: Validators.name,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 16),

                            // Email Field
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
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 16),

                            // Message Field
                            TextFormField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                                hintText: 'Enter your message',
                                prefixIcon: Icon(Icons.message_outlined),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 5,
                              textInputAction: TextInputAction.done,
                              validator: (value) => Validators.minLength(
                                value,
                                10,
                                'Message',
                              ),
                              enabled: !_isSubmitting,
                              onFieldSubmitted: (_) => _handleSubmit(),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text('Send Message'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
