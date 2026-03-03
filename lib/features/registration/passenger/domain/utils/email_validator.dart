class EmailValidator {
  static bool isValid(String email) {
    return email.contains('@') && email.contains('.') && email.length >= 5;
  }
}
