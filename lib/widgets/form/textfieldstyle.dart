import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';

InputDecoration textFieldStyle(
    {String? label,
    String? hint,
    Color? backgroundColor,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? suffix,
    String? prefix,
    String? counterText,
    bool? error,
    FloatingLabelBehavior? floatingLabelBehavior,
    EdgeInsets? contentPadding,
    Color? focusBorderColor,
    bool enabled = true}) {
  return InputDecoration(
      enabled: enabled,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(5),
      ),
      contentPadding: contentPadding,
      counterText: counterText,
      prefix: prefix != null ? Text(prefix) : null,
      prefixIcon: prefixIcon,
      floatingLabelBehavior: floatingLabelBehavior,
      // fillColor: backgroundColor ?? Colors.grey[50],
      // fillColor: Colors.transparent,
      fillColor: enabled ? Colors.grey[50] : Colors.grey[300],
      filled: true,
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 0.0),
      ),
      errorStyle: const TextStyle(color: Colors.red),
      suffix: suffix != null ? Text(suffix) : null,
      suffixIcon: suffixIcon,
      hintText: hint,
      labelText: label,
      focusColor: ACCENT_PRIMARY,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: focusBorderColor ?? ACCENT_PRIMARY,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      enabledBorder: error != null && error == true
          ? const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            )
          : const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black45,
                width: .5,
              ),
            ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black45,
          width: .5,
        ),
      ));
}
