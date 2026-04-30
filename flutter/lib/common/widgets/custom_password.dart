// https://github.com/rodrigobastosv/fancy_password_field
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:get/get.dart';
import 'package:password_strength/password_strength.dart';

abstract class ValidationRule {
  String get name;
  bool validate(String value);
}

class UppercaseValidationRule extends ValidationRule {
  @override
  String get name => translate('uppercase');
  @override
  bool validate(String value) {
    return value.runes.any((int rune) {
      var character = String.fromCharCode(rune);
      return character.toUpperCase() == character &&
          character.toLowerCase() != character;
    });
  }
}

class LowercaseValidationRule extends ValidationRule {
  @override
  String get name => translate('lowercase');

  @override
  bool validate(String value) {
    return value.runes.any((int rune) {
      var character = String.fromCharCode(rune);
      return character.toLowerCase() == character &&
          character.toUpperCase() != character;
    });
  }
}

class DigitValidationRule extends ValidationRule {
  @override
  String get name => translate('digit');

  @override
  bool validate(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }
}

class SpecialCharacterValidationRule extends ValidationRule {
  @override
  String get name => translate('special character');

  @override
  bool validate(String value) {
    return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}

class MinCharactersValidationRule extends ValidationRule {
  final int _numberOfCharacters;
  MinCharactersValidationRule(this._numberOfCharacters);

  @override
  String get name => translate('length>=$_numberOfCharacters');

  @override
  bool validate(String value) {
    return value.length >= _numberOfCharacters;
  }
}

class NoSimplePatternRule extends ValidationRule {
  @override
  String get name => translate('no simple pattern');

  @override
  bool validate(String value) {
    if (value.length < 2) return true;
    final s = value.toLowerCase();
    final len = s.length;

    // 检测 1：全部相同字符（11111111, aaaaaaaa）
    if (s.runes.toSet().length == 1) return false;

    // 检测 2：连续递增或递减序列（12345678, abcdefgh, 87654321）
    bool asc = true, desc = true;
    for (int i = 1; i < len; i++) {
      if (s.codeUnitAt(i) != s.codeUnitAt(i - 1) + 1) asc = false;
      if (s.codeUnitAt(i) != s.codeUnitAt(i - 1) - 1) desc = false;
    }
    if (asc || desc) return false;

    // 检测 3：分段重复（11112222, aaaabbbb）
    // 将字符串分解为相同字符连续块（runs）
    final runs = <int>[];
    int i = 0;
    while (i < len) {
      int j = i;
      while (j < len && s[j] == s[i]) j++;
      runs.add(j - i);
      i = j;
    }
    // 若由 <= 4 段组成，且每段长度 >= 2，认为是简单分段模式
    if (runs.length <= 4 && runs.every((r) => r >= 2)) return false;

    // 检测 4：重复子串模式（12341234, abababab）
    for (int period = 1; period <= len ~/ 2; period++) {
      if (len % period != 0) continue;
      final pattern = s.substring(0, period);
      bool isRepeat = true;
      for (int k = period; k < len; k += period) {
        if (s.substring(k, k + period) != pattern) {
          isRepeat = false;
          break;
        }
      }
      if (isRepeat) return false;
    }

    return true;
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final RxString password;
  final double weakMedium = 0.33;
  final double mediumStrong = 0.67;
  const PasswordStrengthIndicator({Key? key, required this.password})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var strength = estimatePasswordStrength(password.value);
      return Row(
        children: [
          Expanded(
              child: _indicator(
                  password.isEmpty ? Colors.grey : _getColor(strength))),
          Expanded(
              child: _indicator(password.isEmpty || strength < weakMedium
                  ? Colors.grey
                  : _getColor(strength))),
          Expanded(
              child: _indicator(password.isEmpty || strength < mediumStrong
                  ? Colors.grey
                  : _getColor(strength))),
          Text(password.isEmpty ? '' : translate(_getLabel(strength)))
              .marginOnly(left: password.isEmpty ? 0 : 8),
        ],
      );
    });
  }

  Widget _indicator(Color color) {
    return Container(
      height: 8,
      color: color,
    );
  }

  String _getLabel(double strength) {
    if (strength < weakMedium) {
      return 'Weak';
    } else if (strength < mediumStrong) {
      return 'Medium';
    } else {
      return 'Strong';
    }
  }

  Color _getColor(double strength) {
    if (strength < weakMedium) {
      return Colors.yellow;
    } else if (strength < mediumStrong) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }
}
