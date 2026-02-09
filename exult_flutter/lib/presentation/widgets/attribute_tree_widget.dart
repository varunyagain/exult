import 'package:flutter/material.dart';
import 'package:exult_flutter/core/constants/attribute_tree.dart';
import 'package:exult_flutter/core/constants/genre_tree.dart';

/// Tri-state for a category node's selection.
enum _CheckState { none, some, all }

/// A collapsible category tree with tri-state checkboxes.
/// Only shows categories that have at least one book.
class AttributeTreeWidget extends StatefulWidget {
  /// The tree data to render. Defaults to [ecorfanCategoryTree].
  final List<AttributeNode> treeData;

  /// Header title. Defaults to 'Categories'.
  final String title;

  /// Header icon. Defaults to [Icons.category].
  final IconData icon;

  /// Set of all category names present across books in the catalog.
  final Set<String> availableValues;

  /// Currently selected category names (leaf or any level).
  final Set<String> selectedValues;

  /// Called whenever the selection changes.
  final ValueChanged<Set<String>> onSelectionChanged;

  /// Optional search query to filter the tree. Matching nodes and their
  /// ancestors are shown; ancestor nodes are auto-expanded.
  final String searchQuery;

  const AttributeTreeWidget({
    super.key,
    this.treeData = ecorfanCategoryTree,
    this.title = 'Categories',
    this.icon = Icons.category,
    required this.availableValues,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.searchQuery = '',
  });

  @override
  State<AttributeTreeWidget> createState() => _AttributeTreeWidgetState();
}

class _AttributeTreeWidgetState extends State<AttributeTreeWidget> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final visibleRoots = widget.treeData
        .where((node) => _isVisible(node))
        .toList();

    if (visibleRoots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No categories available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with clear button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (widget.selectedValues.isNotEmpty)
                TextButton(
                  onPressed: () => widget.onSelectionChanged({}),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: visibleRoots
                .map((node) => _buildNode(context, node, 0))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Check if a node or any of its descendants has books.
  bool _hasBooks(AttributeNode node) {
    if (widget.availableValues.contains(node.name)) return true;
    return node.children.any((child) => _hasBooks(child));
  }

  /// Check if a node or any of its descendants matches the search query.
  bool _matchesSearch(AttributeNode node) {
    if (widget.searchQuery.isEmpty) return true;
    final query = widget.searchQuery.toLowerCase();
    if (node.name.toLowerCase().contains(query)) return true;
    return node.children.any((child) => _matchesSearch(child));
  }

  /// Whether a node should be displayed (has books AND matches search).
  bool _isVisible(AttributeNode node) {
    return _hasBooks(node) && _matchesSearch(node);
  }

  /// Compute the check state for a node.
  _CheckState _checkState(AttributeNode node) {
    if (node.children.isEmpty) {
      // Leaf node
      return widget.selectedValues.contains(node.name)
          ? _CheckState.all
          : _CheckState.none;
    }

    // Non-leaf: check visible children
    final visibleChildren = node.children.where((c) => _isVisible(c)).toList();
    if (visibleChildren.isEmpty) {
      return widget.selectedValues.contains(node.name)
          ? _CheckState.all
          : _CheckState.none;
    }

    final childStates = visibleChildren.map((c) => _checkState(c)).toList();
    if (childStates.every((s) => s == _CheckState.all)) return _CheckState.all;
    if (childStates.every((s) => s == _CheckState.none)) return _CheckState.none;
    return _CheckState.some;
  }

  /// Get all selectable category names under a node (only those with books).
  Set<String> _selectableNames(AttributeNode node) {
    final result = <String>{};
    if (widget.availableValues.contains(node.name)) {
      result.add(node.name);
    }
    for (final child in node.children) {
      if (_isVisible(child)) {
        result.addAll(_selectableNames(child));
      }
    }
    return result;
  }

  /// Find all ancestor names for a given node name by walking the tree.
  Set<String> _findAncestors(String nodeName) {
    final result = <String>{};
    bool search(List<AttributeNode> nodes, List<String> path) {
      for (final node in nodes) {
        if (node.name == nodeName) {
          result.addAll(path);
          return true;
        }
        if (node.children.isNotEmpty) {
          path.add(node.name);
          if (search(node.children, path)) return true;
          path.removeLast();
        }
      }
      return false;
    }
    search(widget.treeData, []);
    return result;
  }

  /// Find a node object by name.
  AttributeNode? _findNode(String name, [List<AttributeNode>? nodes]) {
    for (final node in (nodes ?? widget.treeData)) {
      if (node.name == name) return node;
      if (node.children.isNotEmpty) {
        final found = _findNode(name, node.children);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _onNodeTap(AttributeNode node) {
    final state = _checkState(node);
    final names = _selectableNames(node);
    final newSelection = Set<String>.from(widget.selectedValues);

    if (state == _CheckState.all) {
      // Deselect all descendants
      newSelection.removeAll(names);
      // Remove ancestors that no longer have any selected descendants
      for (final ancestorName in _findAncestors(node.name)) {
        final ancestorNode = _findNode(ancestorName);
        if (ancestorNode == null) continue;
        final descendantNames = _selectableNames(ancestorNode)
          ..remove(ancestorName);
        if (descendantNames.intersection(newSelection).isEmpty) {
          newSelection.remove(ancestorName);
        }
      }
    } else {
      // Select all descendants
      newSelection.addAll(names);
      // Also select all ancestors
      for (final ancestorName in _findAncestors(node.name)) {
        if (widget.availableValues.contains(ancestorName)) {
          newSelection.add(ancestorName);
        }
      }
    }

    widget.onSelectionChanged(newSelection);
  }

  Widget _buildNode(BuildContext context, AttributeNode node, int depth) {
    if (!_isVisible(node)) return const SizedBox.shrink();

    final visibleChildren =
        node.children.where((c) => _isVisible(c)).toList();
    final hasChildren = visibleChildren.isNotEmpty;
    final isSearching = widget.searchQuery.isNotEmpty;
    final isExpanded = _expanded.contains(node.name) ||
        (isSearching && hasChildren);
    final state = _checkState(node);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _onNodeTap(node),
          child: Padding(
            padding: EdgeInsets.only(
              left: 8.0 + depth * 20.0,
              right: 8,
              top: 4,
              bottom: 4,
            ),
            child: Row(
              children: [
                // Expand/collapse toggle
                if (hasChildren)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expanded.remove(node.name);
                        } else {
                          _expanded.add(node.name);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        isExpanded
                            ? Icons.expand_more
                            : Icons.chevron_right,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 22),

                const SizedBox(width: 4),

                // Tri-state checkbox
                _TriStateCheckbox(state: state),

                const SizedBox(width: 8),

                // Label
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: depth == 0 ? 13 : 12,
                      fontWeight:
                          depth == 0 ? FontWeight.w600 : FontWeight.normal,
                      color: state != _CheckState.none
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Children (if expanded)
        if (hasChildren && isExpanded)
          ...visibleChildren
              .map((child) => _buildNode(context, child, depth + 1)),
      ],
    );
  }
}

/// A dialog that wraps [AttributeTreeWidget] for picking from any tree.
class AttributePickerDialog extends StatefulWidget {
  final Set<String> initialSelection;
  final List<AttributeNode> treeData;
  final Set<String> allNames;
  final String title;
  final IconData icon;

  const AttributePickerDialog({
    super.key,
    required this.initialSelection,
    this.treeData = ecorfanCategoryTree,
    required this.allNames,
    this.title = 'Select Categories',
    this.icon = Icons.category,
  });

  /// Show a category picker dialog.
  static Future<Set<String>?> show(
      BuildContext context, Set<String> currentSelection) {
    return showDialog<Set<String>>(
      context: context,
      builder: (_) => AttributePickerDialog(
        initialSelection: currentSelection,
        allNames: allCategoryNames.toSet(),
      ),
    );
  }

  /// Show a genre picker dialog.
  static Future<Set<String>?> showGenre(
      BuildContext context, Set<String> currentSelection) {
    return showDialog<Set<String>>(
      context: context,
      builder: (_) => AttributePickerDialog(
        initialSelection: currentSelection,
        treeData: writingGenreTree,
        allNames: allGenreNames.toSet(),
        title: 'Select Genres',
        icon: Icons.auto_stories,
      ),
    );
  }

  @override
  State<AttributePickerDialog> createState() => _AttributePickerDialogState();
}

class _AttributePickerDialogState extends State<AttributePickerDialog> {
  late Set<String> _selection;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selection = Set<String>.from(widget.initialSelection);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        height: 450,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AttributeTreeWidget(
                treeData: widget.treeData,
                title: widget.title.replaceFirst('Select ', ''),
                icon: widget.icon,
                availableValues: widget.allNames,
                selectedValues: _selection,
                onSelectionChanged: (newSelection) {
                  setState(() => _selection = newSelection);
                },
                searchQuery: _searchQuery,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selection),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _TriStateCheckbox extends StatelessWidget {
  final _CheckState state;

  const _TriStateCheckbox({required this.state});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    switch (state) {
      case _CheckState.none:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      case _CheckState.some:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.3),
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Center(
            child: Icon(Icons.remove, size: 14, color: Colors.white),
          ),
        );
      case _CheckState.all:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: primaryColor,
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Center(
            child: Icon(Icons.check, size: 14, color: Colors.white),
          ),
        );
    }
  }
}
