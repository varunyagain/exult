/// Form validation utilities
class Validators {
  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number (Indian format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Validate name
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate pincode (Indian format)
  static String? pincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    final pincodeRegex = RegExp(r'^\d{6}$');
    if (!pincodeRegex.hasMatch(value)) {
      return 'Please enter a valid 6-digit pincode';
    }
    return null;
  }

  /// Strip hyphens and spaces from an ISBN, returning digits only.
  static String normalizeIsbn(String isbn) =>
      isbn.replaceAll(RegExp(r'[\s-]'), '');

  /// Validate ISBN (both ISBN-10 and ISBN-13)
  static String? isbn(String? value) {
    if (value == null || value.isEmpty) {
      return null; // ISBN is optional
    }
    final cleanValue = normalizeIsbn(value);
    if (cleanValue.length != 10 && cleanValue.length != 13) {
      return 'ISBN must be 10 or 13 digits';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validate numeric value
  static String? numeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }
}
