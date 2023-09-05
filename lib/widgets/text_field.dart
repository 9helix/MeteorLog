import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors.dart';

class TextForm extends StatelessWidget {
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter> format;
  final EdgeInsets scrollPadding;
  final bool autofocus;
  final String? init;
  final String? text;
  final double round;
  TextForm(
      {this.controller,
      this.init,
      this.enabled = true,
      required this.validator,
      this.keyboardType = TextInputType.text,
      this.format = const [],
      this.scrollPadding = const EdgeInsets.all(0.0),
      this.autofocus = false,
      this.text,
      this.round = 15.0});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        autofocus: autofocus,
        initialValue: init,
        scrollPadding: scrollPadding,
        controller: controller,
        enabled: enabled,
        cursorColor: red,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: red, width: 2.0),
            borderRadius: BorderRadius.circular(round),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: red, width: 1.0),
            borderRadius: BorderRadius.circular(round),
          ),
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: red),
          labelText: text,
        ),
        style: TextStyle(color: red),
        keyboardType: keyboardType,
        inputFormatters: format,
        validator: validator);
  }
}
