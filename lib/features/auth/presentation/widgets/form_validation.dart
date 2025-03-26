class FormValidators {
  static String? passwordValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "Fill in all required fields";
    }
    if (value.length < 6 ) {
      return "Passowrd should be at least 6 characters long";
    }
    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }
  static String? dobValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "Fill in all required fields";
    }
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Date of Birth should follow form DD/MM/YYYY';
    }
    return null;
  }
  static String? phoneValidation(String? value) {
  if (value != null && value.isNotEmpty) {
    if (value.length > 10) {
      return "Phone number can only be a maximum of 10 characters";
    }
  }
  return null;
  }
  static String? emailValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "Fill in all required fields";
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Use a valid email address';
    }
    return null;
  }
}
