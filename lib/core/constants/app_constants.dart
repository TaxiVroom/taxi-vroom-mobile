import 'package:flutter/material.dart';

abstract class AppConstants {
  static const primaryColor = Color(0xFF0066FF);
  static const otpLength = 6;
  static const otpCountdownSeconds = 30;
  static const phoneMinDigitCount = 7;

  // How many items the API gives per page of a long list.
  static const listPageSize = 20;
}
