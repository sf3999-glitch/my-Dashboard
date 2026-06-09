import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;
  final ButtonVariant variant;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: width,
          height: height ?? 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildContent(context, Colors.white),
          ),
        );
      case ButtonVariant.secondary:
        return SizedBox(
          width: width,
          height: height ?? 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
            ),
            child: _buildContent(context, colorScheme.onSecondaryContainer),
          ),
        );
      case ButtonVariant.outline:
        return SizedBox(
          width: width,
          height: height ?? 50,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildContent(context, colorScheme.primary),
          ),
        );
      case ButtonVariant.danger:
        return SizedBox(
          width: width,
          height: height ?? 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: _buildContent(context, Colors.white),
          ),
        );
    }
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 15,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    );
  }
}
