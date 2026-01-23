import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final InputDecoration? decoration;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final List<String>? autofillHints;

  const PasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.hintText,
    this.decoration,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.textInputAction,
    this.onEditingComplete,
    this.autofillHints,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_isVisible,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      autofillHints: widget.autofillHints ?? const [AutofillHints.password],
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        labelText: widget.decoration?.labelText ?? widget.labelText,
        hintText: widget.decoration?.hintText ?? widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isVisible = !_isVisible),
        ),
      ),
    );
  }
}
