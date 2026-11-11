// "+33700000007" (E.164, as the API stores it) -> "+33 7 00 00 00 07". Any
// other number, foreign or unexpected, stays as it is.
String formatPhone(String phone) {
  final isFrench = RegExp(r'^\+33\d{9}$').hasMatch(phone);
  if (!isFrench) return phone;
  final digits = phone.substring(3);
  final pairs = [
    for (var i = 1; i < digits.length; i += 2) digits.substring(i, i + 2),
  ];
  return '+33 ${digits[0]} ${pairs.join(' ')}';
}
