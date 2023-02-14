import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputItem extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final List<Widget> actions;
  final bool obscureText;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final ValueChanged onChange;

  InputItem(
    this.label,
    this.hintText,
    this.controller, {
    this.actions,
    this.obscureText,
    this.inputFormatters,
    this.keyboardType,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: AppPalette.tips, fontSize: 14)),
        SizedBox(width: 15),
        Expanded(
          child: TextField(
            maxLines: 1,
            controller: controller,
            onChanged: onChange,
            inputFormatters: inputFormatters ?? [],
            keyboardType: keyboardType ?? TextInputType.emailAddress,
            obscureText: obscureText ?? false,
            style: TextStyle(color: AppPalette.dark, fontSize: 14, height: 1),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: AppPalette.hint, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        ...actions ?? []
      ],
    ).toTagView(60, Colors.white, padding: EdgeInsets.only(left: 20, right: 20));
  }
}
