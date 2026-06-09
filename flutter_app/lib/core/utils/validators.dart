class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  static String? intRange(String? value, int min, int max, [String fieldName = 'Value']) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    final n = int.tryParse(value);
    if (n == null) return 'Enter a valid integer';
    if (n < min || n > max) return '$fieldName must be between $min and $max';
    return null;
  }
}
