import 'package:drive/src/controller/language_controller.dart';
import 'package:flutter/services.dart';

class Validators {
  static String? validateDigits(String value, String type, int length) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return currentLanguage['valid_typeIsRequired']
          .toString()
          .replaceAll('{0}', type);
    } else if (value.length != length) {
      String replace1 =
          currentLanguage['valid_typeLen'].toString().replaceAll('{0}', type);
      String replace2 = replace1.replaceAll('{1}', '$length');
      return replace2;
    } else if (!regExp.hasMatch(value)) {
      String replace1 = currentLanguage['valid_typeMustBeNumber']
          .toString()
          .replaceAll('{0}', type);
      String replace2 = replace1.replaceAll('{1}', '100');
      return replace2;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value == null || value.length <= 0) {
      return currentLanguage['valid_emailRequired'];
    } else if (!regExp.hasMatch(value)) {
      return currentLanguage['valid_typeIsInvalid']
          .toString()
          .replaceAll('{0}', 'Email');
    } else {
      return null;
    }
  }

  static String? validateLoginEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    String digitsPatttern = r'(^[0-9]*$)';

    RegExp regExp = new RegExp(pattern);
    RegExp digitsPattternregExp = new RegExp(digitsPatttern);
    if (value == null || value.length <= 0) {
      return currentLanguage['valid_emailRequired'];
    } else if (!regExp.hasMatch(value)) {
      if (!digitsPattternregExp.hasMatch(value)) {
        return currentLanguage['valid_typeIsInvalid']
            .toString()
            .replaceAll('{0}', 'Email');
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String? validateText({String? value, String? text, int? maxLen}) {
    if (value.toString().length == 0) {
      return currentLanguage['valid_typeIsRequired']
          .toString()
          .replaceAll('{0}', text ?? 'This field');
    } else {
      if (value.toString().isNotEmpty) {
        if (value.toString().length < 2) {
          String replace1 = currentLanguage['valid_textLenMin']
              .toString()
              .replaceAll('{0}', '$text');
          String replace2 = replace1.replaceAll('{1}', '2');
          return replace2;
        } else if (maxLen != null && value.toString().length > maxLen) {
          if (value.toString().length < 2) {
            String replace1 = currentLanguage['valid_textLenMin']
                .toString()
                .replaceAll('{0}', '$text');
            String replace2 = replace1.replaceAll('{1}', '$maxLen');
            return replace2;
          } else {
            return null;
          }
        }
      }
      return null;
    }
  }

  static String? validatePassword(String value) {
    String pattern =
        r'^.*(?=.{8,})((?=.*[!?@#$%^&*()\-_=+{};:,<.>]){1})(?=.*\d)((?=.*[a-z]){1})((?=.*[A-Z]){1}).*$';
    RegExp regExp = new RegExp(pattern);
    if (value.isEmpty) {
      return currentLanguage['valid_passwordRequired'];
    } else if (!regExp.hasMatch(value)) {
      return currentLanguage['valid_passwordRules'];
    } else {
      return null;
    }
  }

  String? validatepass(String value) {
    if (value.isEmpty) {
      return currentLanguage['valid_passwordPlsEnter'];
    }
    if (value.length < 9) {
      String replace1 =
          currentLanguage['valid_textLenMin'].toString().replaceAll('{0}', '');
      String replace2 = replace1.replaceAll('{1}', '8');
      return replace2;
    } else {
      return null;
    }
  }
}

class ReplaceCommaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.replaceAll('.', ','),
      selection: newValue.selection,
    );
  }
}
