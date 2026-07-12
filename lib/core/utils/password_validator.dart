/// Strong-password policy shared by the signup form and the "add password"
/// flow on the sign-in methods screen: 8+ chars, an uppercase letter, a number,
/// and a special character. Returns an error string, or null when valid.
String? validateStrongPassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required.';
  if (value.length < 8) return 'Must be at least 8 characters.';
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Must contain an uppercase letter.';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain a number.';
  if (!RegExp(r'[@#\$%^&*!?]').hasMatch(value)) {
    return 'Must contain a special character.';
  }
  return null;
}
