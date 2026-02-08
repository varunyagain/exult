import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';
import 'package:exult_flutter/core/constants/firebase_constants.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/domain/models/user_model.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _roleFilter;
  String _sortColumn = 'name';
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersWithDetails = ref.watch(usersWithDetailsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.books);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscribers'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(usersWithDetailsProvider),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showUserDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add User'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: usersWithDetails.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No users found'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search and Role Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value.toLowerCase());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _roleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(
                              value: 'subscriber',
                              child: Text('Subscriber')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) {
                          setState(() => _roleFilter = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Data Table
              Expanded(
                child: () {
                  final filteredUsers = _filterAndSortUsers(users);

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No users match your filters',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildDataTable(context, ref, filteredUsers),
                    ),
                  );
                }(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(usersWithDetailsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<UserWithDetails> _filterAndSortUsers(List<UserWithDetails> users) {
    var filtered = users.where((u) {
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            u.user.displayName.toLowerCase().contains(_searchQuery) ||
                u.user.email.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      if (_roleFilter != null && u.user.role.name != _roleFilter) {
        return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      int comparison;
      switch (_sortColumn) {
        case 'name':
          comparison = a.user.displayName
              .toLowerCase()
              .compareTo(b.user.displayName.toLowerCase());
          break;
        case 'email':
          comparison = a.user.email
              .toLowerCase()
              .compareTo(b.user.email.toLowerCase());
          break;
        case 'role':
          comparison = a.user.role.name.compareTo(b.user.role.name);
          break;
        case 'activeLoans':
          comparison = a.activeLoanCount.compareTo(b.activeLoanCount);
          break;
        case 'joined':
          comparison = a.user.createdAt.compareTo(b.user.createdAt);
          break;
        default:
          comparison = a.user.displayName.compareTo(b.user.displayName);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Widget _buildDataTable(
      BuildContext context, WidgetRef ref, List<UserWithDetails> users) {
    final dateFormat = DateFormat('d MMM yyyy');

    return DataTable(
      sortColumnIndex: _getSortColumnIndex(),
      sortAscending: _sortAscending,
      headingRowColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      columns: [
        DataColumn(
          label: const Text('Name'),
          onSort: (_, ascending) => _onSort('name', ascending),
        ),
        DataColumn(
          label: const Text('Email'),
          onSort: (_, ascending) => _onSort('email', ascending),
        ),
        DataColumn(
          label: const Text('Role'),
          onSort: (_, ascending) => _onSort('role', ascending),
        ),
        const DataColumn(label: Text('Subscription')),
        const DataColumn(label: Text('Plan')),
        DataColumn(
          label: const Text('Active Loans'),
          numeric: true,
          onSort: (_, ascending) => _onSort('activeLoans', ascending),
        ),
        const DataColumn(
          label: Text('Remaining'),
          numeric: true,
        ),
        DataColumn(
          label: const Text('Joined'),
          onSort: (_, ascending) => _onSort('joined', ascending),
        ),
        const DataColumn(label: Text('Actions')),
      ],
      rows: users.map((userDetails) {
        final user = userDetails.user;
        return DataRow(
          cells: [
            DataCell(
              SizedBox(
                width: 160,
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName : 'No Name',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 200,
                child: Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(_buildRoleBadge(context, user.role)),
            DataCell(_buildSubscriptionBadge(context, userDetails)),
            DataCell(Text(
              userDetails.subscription != null
                  ? userDetails.subscription!.tier.displayName
                  : '-',
            )),
            DataCell(Text('${userDetails.activeLoanCount}')),
            DataCell(Text(
              userDetails.hasActiveSubscription
                  ? '${userDetails.remainingCapacity}'
                  : '-',
            )),
            DataCell(Text(dateFormat.format(user.createdAt))),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 20),
                    tooltip: 'View Details',
                    onPressed: () {
                      context.go(
                          '${RouteConstants.adminSubscribers}/${user.uid}');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: 'Delete',
                    color: Colors.red,
                    onPressed: () =>
                        _confirmDelete(context, ref, userDetails),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  int _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'name':
        return 0;
      case 'email':
        return 1;
      case 'role':
        return 2;
      case 'activeLoans':
        return 5;
      case 'joined':
        return 7;
      default:
        return 0;
    }
  }

  void _onSort(String column, bool ascending) {
    setState(() {
      _sortColumn = column;
      _sortAscending = ascending;
    });
  }

  Widget _buildRoleBadge(BuildContext context, UserRole role) {
    final isAdmin = role == UserRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.purple.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin ? Colors.purple.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Subscriber',
        style: TextStyle(
          fontSize: 12,
          color: isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadge(
      BuildContext context, UserWithDetails userDetails) {
    final isActive = userDetails.hasActiveSubscription;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        userDetails.subscriptionStatus,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _showUserDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<UserModel>(
      context: context,
      builder: (context) => const UserFormDialog(),
    );

    if (result != null) {
      final userRepository = ref.read(userRepositoryProvider);
      try {
        await userRepository.createUser(result);

        // Send invite email via Firebase Trigger Email extension
        final signUpUrl =
            '${AppConstants.appUrl}${RouteConstants.signUp}';
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.mailCollection)
            .add({
          'to': [result.email],
          'message': {
            'subject': 'You\'re invited to join ${AppConstants.appName}!',
            'html': '''
<h2>Welcome to ${AppConstants.appName}, ${result.displayName}!</h2>
<p>You've been invited to join our book lending platform.</p>
<p>To get started, please create your account using the link below:</p>
<p><a href="$signUpUrl">Sign up at ${AppConstants.appName}</a></p>
<p>Please sign up with this email address: <strong>${result.email}</strong></p>
<p>Happy reading!<br>The ${AppConstants.appName} Team</p>
''',
          },
        });

        ref.invalidate(usersWithDetailsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created and invite email sent'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, UserWithDetails userDetails) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete "${userDetails.user.displayName.isNotEmpty ? userDetails.user.displayName : userDetails.user.email}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userRepository = ref.read(userRepositoryProvider);
        await userRepository.deleteUser(userDetails.user.uid);
        ref.invalidate(usersWithDetailsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  UserRole _role = UserRole.subscriber;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Display name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role == UserRole.admin
                          ? 'Admin'
                          : 'Subscriber'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _role = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'An invite email will be sent to this address with sign-up instructions.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add User'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        uid: const Uuid().v4(),
        email: _emailController.text.trim(),
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: _role,
        createdAt: DateTime.now(),
      );

      Navigator.of(context).pop(user);
    }
  }
}
