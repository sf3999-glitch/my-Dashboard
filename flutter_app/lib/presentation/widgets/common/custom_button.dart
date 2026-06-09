import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outline, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool iconLeading;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height,
    this.icon,
    this.iconLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabled = isLoading || onPressed == null;

    Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _getForeground(colorScheme)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null && iconLeading) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              if (icon != null && !iconLeading) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
            ],
          );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final size = SizedBox(width: width, height: height ?? 52, child: null);

    if (variant == ButtonVariant.outline) {
      return SizedBox(
        width: width,
        height: height ?? 52,
        child: OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            shape: shape,
          ),
          child: content,
        ),
      );
    }

    if (variant == ButtonVariant.secondary) {
      return SizedBox(
        width: width,
        height: height ?? 52,
        child: FilledButton.tonal(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(shape: shape),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 52,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: variant == ButtonVariant.danger ? colorScheme.error : null,
          shape: shape,
        ),
        child: content,
      ),
    );
  }

  Color _getForeground(ColorScheme cs) {
    switch (variant) {
      case ButtonVariant.primary: return cs.onPrimary;
      case ButtonVariant.secondary: return cs.onSecondaryContainer;
      case ButtonVariant.outline: return cs.primary;
      case ButtonVariant.danger: return cs.onError;
    }
  }
}
