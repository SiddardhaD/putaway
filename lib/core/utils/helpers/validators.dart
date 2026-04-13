class Validators {
  Validators._();

  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    return null;
  }

  static String? validateUsername(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }

  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (int.tryParse(value) == null && double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    
    return null;
  }

  static String? validateQuantity(String? value, {int min = 1, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Enter a valid quantity';
    }
    
    if (quantity < min) {
      return 'Quantity must be at least $min';
    }
    
    if (max != null && quantity > max) {
      return 'Quantity must not exceed $max';
    }
    
    return null;
  }

  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (minLength != null && value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }
    
    return null;
  }

  static String? validateMatch(String? value, String? compareValue, {String? fieldName}) {
    if (value != compareValue) {
      return '${fieldName ?? 'Values'} do not match';
    }
    return null;
  }
}
