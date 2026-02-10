import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/presentation/widgets/attribute_tree_widget.dart';

/// Result type for the user book form dialog.
/// When [isDuplicate] is true, [existingBook] is the matched book to add a copy to.
class BookFormResult {
  final Book? book;
  final bool isDuplicate;
  final Book? existingBook;

  const BookFormResult({this.book, this.isDuplicate = false, this.existingBook});
}

/// Generalized book form dialog used by both admin and user flows.
class BookFormDialog extends StatefulWidget {
  final Book? book;
  final bool isUserMode;
  final Future<Book?> Function(String isbn)? onIsbnLookup;

  const BookFormDialog({
    super.key,
    this.book,
    this.isUserMode = false,
    this.onIsbnLookup,
  });

  @override
  State<BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<BookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _depositController;
  late final TextEditingController _totalCopiesController;
  late final TextEditingController _availableCopiesController;

  late BookOwnerType _ownerType;
  late BookStatus _status;
  late List<String> _selectedCategories;
  late List<String> _selectedGenres;

  final FocusNode _isbnFocusNode = FocusNode();
  bool _isCheckingIsbn = false;
  Book? _isbnMatch;
  String _lastCheckedIsbn = '';

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _descriptionController =
        TextEditingController(text: book?.description ?? '');
    _coverUrlController =
        TextEditingController(text: book?.coverImageUrl ?? '');
    _depositController =
        TextEditingController(text: book?.depositAmount.toString() ?? '200');
    _totalCopiesController =
        TextEditingController(text: book?.totalCopies.toString() ?? '1');
    _availableCopiesController =
        TextEditingController(text: book?.availableCopies.toString() ?? '1');

    _ownerType = widget.isUserMode
        ? BookOwnerType.user
        : (book?.ownerType ?? BookOwnerType.business);
    _status = widget.isUserMode
        ? (book?.status ?? BookStatus.pending)
        : (book?.status ?? BookStatus.available);
    _selectedCategories = book?.categories.toList() ?? [];
    _selectedGenres = book?.genres.toList() ?? [];

    // Auto-check ISBN when focus leaves the field
    if (widget.isUserMode && widget.onIsbnLookup != null) {
      _isbnFocusNode.addListener(_onIsbnFocusChange);
    }
  }

  @override
  void dispose() {
    _isbnFocusNode.removeListener(_onIsbnFocusChange);
    _isbnFocusNode.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    _depositController.dispose();
    _totalCopiesController.dispose();
    _availableCopiesController.dispose();
    super.dispose();
  }

  void _onIsbnFocusChange() {
    if (!_isbnFocusNode.hasFocus) {
      _checkIsbn();
    }
  }

  Future<void> _checkIsbn() async {
    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty || widget.onIsbnLookup == null) {
      // Clear any previous match if ISBN was emptied
      if (_isbnMatch != null || _lastCheckedIsbn.isNotEmpty) {
        setState(() {
          _isbnMatch = null;
          _lastCheckedIsbn = '';
        });
      }
      return;
    }
    // Don't re-check the same ISBN
    if (isbn == _lastCheckedIsbn) return;

    setState(() {
      _isCheckingIsbn = true;
      _isbnMatch = null;
    });

    try {
      final match = await widget.onIsbnLookup!(isbn);
      if (!mounted) return;
      setState(() {
        _isbnMatch = match;
        _lastCheckedIsbn = isbn;
        _isCheckingIsbn = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckingIsbn = false;
        _lastCheckedIsbn = isbn;
      });
    }
  }

  bool get _hasIsbnMatch => _isbnMatch != null;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;
    final isUserNew = widget.isUserMode && !isEditing;

    return AlertDialog(
      title: Text(
        widget.isUserMode
            ? (isEditing ? 'Edit My Book' : 'List a Book')
            : (isEditing ? 'Edit Book' : 'Add New Book'),
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ISBN field for user mode (new books only) — auto-checks on blur
              if (isUserNew) ...[
                TextFormField(
                  controller: _isbnController,
                  focusNode: _isbnFocusNode,
                  decoration: InputDecoration(
                    labelText: 'ISBN',
                    border: const OutlineInputBorder(),
                    hintText: 'Enter ISBN to check catalog',
                    suffixIcon: _isCheckingIsbn
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (_) {
                    // Clear match when ISBN changes
                    if (_hasIsbnMatch) {
                      setState(() {
                        _isbnMatch = null;
                        _lastCheckedIsbn = '';
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Show matched book details as read-only
                if (_hasIsbnMatch) ...[
                  _buildIsbnMatchCard(context),
                ],
              ],

              // Show the editable form only when there's no ISBN match (user mode)
              // or always for admin mode / editing
              if (!isUserNew || !_hasIsbnMatch) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Author Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Title is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _authorController,
                              decoration: const InputDecoration(
                                labelText: 'Author *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Author is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ISBN (for admin mode or editing) and Cover URL Row
                      if (!widget.isUserMode || isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _isbnController,
                                decoration: const InputDecoration(
                                  labelText: 'ISBN',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _coverUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Cover Image URL',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _coverUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Cover Image URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Deposit and Copies
                      if (widget.isUserMode) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _depositController,
                                decoration: const InputDecoration(
                                  labelText: 'Deposit Amount (\u20B9) *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid amount';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _totalCopiesController,
                                decoration: const InputDecoration(
                                  labelText: 'Number of Copies *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _depositController,
                                decoration: const InputDecoration(
                                  labelText: 'Deposit Amount (\u20B9) *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid amount';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _totalCopiesController,
                                decoration: const InputDecoration(
                                  labelText: 'Total Copies *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _availableCopiesController,
                                decoration: const InputDecoration(
                                  labelText: 'Available Copies *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final available = int.tryParse(value);
                                  if (available == null) {
                                    return 'Invalid number';
                                  }
                                  final total =
                                      int.tryParse(_totalCopiesController.text) ?? 0;
                                  if (available > total) {
                                    return 'Cannot exceed total';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Owner Type and Status (admin only)
                      if (!widget.isUserMode) ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<BookOwnerType>(
                                value: _ownerType,
                                decoration: const InputDecoration(
                                  labelText: 'Owner Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: BookOwnerType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type == BookOwnerType.business
                                        ? 'Business'
                                        : 'Community'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _ownerType = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<BookStatus>(
                                value: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                items: BookStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.displayName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _status = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Categories
                      Row(
                        children: [
                          Text(
                            'Categories',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final result = await AttributePickerDialog.show(
                                context,
                                _selectedCategories.toSet(),
                              );
                              if (result != null) {
                                setState(() {
                                  _selectedCategories = result.toList();
                                });
                              }
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Select'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_selectedCategories.isEmpty)
                        Text(
                          'No categories selected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedCategories.map((category) {
                            return Chip(
                              label:
                                  Text(category, style: const TextStyle(fontSize: 12)),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategories.remove(category);
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),

                      // Genres
                      Row(
                        children: [
                          Text(
                            'Genres',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final result = await AttributePickerDialog.showGenre(
                                context,
                                _selectedGenres.toSet(),
                              );
                              if (result != null) {
                                setState(() {
                                  _selectedGenres = result.toList();
                                });
                              }
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Select'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_selectedGenres.isEmpty)
                        Text(
                          'No genres selected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedGenres.map((genre) {
                            return Chip(
                              label:
                                  Text(genre, style: const TextStyle(fontSize: 12)),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _selectedGenres.remove(genre);
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Only show submit button when there's no ISBN match blocking
        if (!isUserNew || !_hasIsbnMatch)
          FilledButton(
            onPressed: _submit,
            child: Text(widget.book != null ? 'Update' : (widget.isUserMode ? 'List Book' : 'Add Book')),
          ),
      ],
    );
  }

  /// Build the read-only card showing matched book details with "Add My Copy" action.
  Widget _buildIsbnMatchCard(BuildContext context) {
    final match = _isbnMatch!;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Book found in catalog',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cover + details side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover thumbnail
                if (match.coverImageUrl != null &&
                    match.coverImageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      match.coverImageUrl!,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.book, size: 32),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.book, size: 32),
                  ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${match.author}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      if (match.isbn != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ISBN: ${match.isbn}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _detailChip(
                            Icons.content_copy,
                            '${match.totalCopies} copies',
                          ),
                          const SizedBox(width: 8),
                          _detailChip(
                            Icons.account_balance_wallet_outlined,
                            'Deposit: ${currencyFormat.format(match.depositAmount)}',
                          ),
                        ],
                      ),
                      if (match.categories.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: match.categories.take(3).map((cat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'This book is already in our catalog. Your copy will be added and auto-approved.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(BookFormResult(
                    isDuplicate: true,
                    existingBook: _isbnMatch,
                  ));
                },
                icon: const Icon(Icons.add),
                label: const Text('Add My Copy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final totalCopies = int.parse(_totalCopiesController.text);
      final availableCopies = widget.isUserMode
          ? totalCopies
          : int.parse(_availableCopiesController.text);

      final book = Book(
        id: widget.book?.id ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImageUrl: _coverUrlController.text.trim().isEmpty
            ? null
            : _coverUrlController.text.trim(),
        ownerType: _ownerType,
        ownerId: widget.book?.ownerId,
        contributors: widget.book?.contributors ?? {},
        contributorIds: widget.book?.contributorIds ?? [],
        categories: _selectedCategories,
        genres: _selectedGenres,
        depositAmount: double.parse(_depositController.text),
        status: _status,
        totalCopies: totalCopies,
        availableCopies: availableCopies,
        createdAt: widget.book?.createdAt ?? DateTime.now(),
      );

      if (widget.isUserMode) {
        Navigator.of(context).pop(BookFormResult(book: book));
      } else {
        // Admin mode returns Book directly for backward compat
        Navigator.of(context).pop(book);
      }
    }
  }
}
