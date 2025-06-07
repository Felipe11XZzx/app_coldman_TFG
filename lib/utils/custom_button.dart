import 'package:flutter/material.dart';

enum ButtonStyle {
  primary,
  secondary,
  success,
  danger, 
  outline, 
}

class CustomButton extends StatelessWidget {

  final String text;
  final Function myFunction;
  final IconData? icon;
  final ButtonStyle? buttonStyle;
  final bool isLoading;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.myFunction,
    this.icon,
    this.buttonStyle = ButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  Color _getBackgroundColor() {
    switch (buttonStyle) {
      case ButtonStyle.primary:
        return Color(0xFF3B82F6);
      case ButtonStyle.secondary:
        return Color(0xFF06B6D4);
      case ButtonStyle.success:
        return Color(0xFF22C55E); 
      case ButtonStyle.danger:
        return Color(0xFFEF4444); 
      case ButtonStyle.outline:
        return Colors.transparent; 
      default:
        return Color(0xFF3B82F6);
    }
  }

  Color _getTextColor() {
    switch (buttonStyle) {
      case ButtonStyle.outline:
        return Color(0xFF3B82F6);
      default:
        return Colors.white;
    }
  }

  BorderSide? _getBorder() {
    if (buttonStyle == ButtonStyle.outline) {
      return BorderSide(color: Color(0xFF3B82F6), width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : 200,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
            side: _getBorder() ?? BorderSide.none,
          ),
          disabledBackgroundColor: Colors.grey[400],
          disabledForegroundColor: Colors.white,
        ),
        onPressed: isLoading ? null : () {
          myFunction();
        },
        child: isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  buttonStyle == ButtonStyle.outline ? Color(0xFF3B82F6) : Colors.white
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: _getTextColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class CustomAdminButton extends StatelessWidget {
  final String text;
  final Function myFunction;
  final IconData? icon;
  final ButtonStyle? buttonStyle;
  final bool isLoading;
  final bool isFullWidth;

  const CustomAdminButton({
    super.key,
    required this.text,
    required this.myFunction,
    this.icon,
    this.buttonStyle = ButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = true, 
  });

  Color _getBackgroundColor() {
    switch (buttonStyle) {
      case ButtonStyle.primary:
        return Color(0xFF3B82F6); 
      case ButtonStyle.secondary:
        return Color(0xFF06B6D4);
      case ButtonStyle.success:
        return Color(0xFF22C55E); 
      case ButtonStyle.danger:
        return Color(0xFFEF4444); 
      case ButtonStyle.outline:
        return Colors.transparent; 
      default:
        return Color(0xFF3B82F6);
    }
  }

  Color _getTextColor() {
    switch (buttonStyle) {
      case ButtonStyle.outline:
        return Color(0xFF3B82F6); 
      default:
        return Colors.white;
    }
  }

  BorderSide? _getBorder() {
    if (buttonStyle == ButtonStyle.outline) {
      return BorderSide(color: Color(0xFF3B82F6), width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : 300,
      height: 56, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
            side: _getBorder() ?? BorderSide.none,
          ),
          disabledBackgroundColor: Colors.grey[400],
          disabledForegroundColor: Colors.white,
        ),
        onPressed: isLoading ? null : () {
          myFunction();
        },
        child: isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  buttonStyle == ButtonStyle.outline ? Color(0xFF3B82F6) : Colors.white
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: _getTextColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final Function myFunction;
  final ButtonStyle? buttonStyle;
  final bool isLoading;
  final double? size;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.myFunction,
    this.buttonStyle = ButtonStyle.primary,
    this.isLoading = false,
    this.size = 48,
  });

  Color _getBackgroundColor() {
    switch (buttonStyle) {
      case ButtonStyle.primary:
        return Color(0xFF3B82F6);
      case ButtonStyle.secondary:
        return Color(0xFF06B6D4);
      case ButtonStyle.success:
        return Color(0xFF22C55E);
      case ButtonStyle.danger:
        return Color(0xFFEF4444);
      case ButtonStyle.outline:
        return Colors.transparent;
      default:
        return Color(0xFF3B82F6);
    }
  }

  Color _getIconColor() {
    switch (buttonStyle) {
      case ButtonStyle.outline:
        return Color(0xFF3B82F6);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: buttonStyle == ButtonStyle.outline 
                ? BorderSide(color: Color(0xFF3B82F6), width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: isLoading ? null : () {
          myFunction();
        },
        child: isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
              ),
            )
          : Icon(
              icon,
              color: _getIconColor(),
              size: size! * 0.4,
            ),
      ),
    );
  }
  
}