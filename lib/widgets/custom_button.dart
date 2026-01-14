import 'package:flutter/material.dart';
import 'package:rosca_app/theme/app_spacing.dart';
import 'package:rosca_app/theme/app_theme.dart';

enum ButtonType { primary, secondary, outline, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.height = 48,
    this.borderRadius = AppSpacing.radiusMd,
  }) : super(key: key);

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.danger:
        return AppColors.error;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return AppColors.textSecondary;
      case ButtonType.outline:
        return AppColors.textSecondary;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.danger:
        return AppColors.error;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(context),
          foregroundColor: _getTextColor(context),
          disabledBackgroundColor: _getBackgroundColor(context).withOpacity(0.5),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: _getBorderColor(context),
              width: type == ButtonType.outline ? 2 : 0,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(context)),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool underline;
  final EdgeInsetsGeometry padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.underline = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? AppColors.primary,
          fontSize: fontSize,
          fontWeight: fontWeight,
          decoration: underline ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}

// class CustomIconButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final IconData icon;
//   final Color? backgroundColor;
//   final Color? iconColor;
//   final double size;
//   final double iconSize;
//   final bool isOutlined;

//   const CustomIconButton({
//     Key? key,
//     required this.onPressed,
//     required this.icon,
//     this.backgroundColor,
//     this.iconColor,
//     this.size = 40,
//     this.iconSize = 20,
//     this.isOutlined = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: isOutlined
//           ? BoxDecoration(
//         border: Border.all(
//           color: backgroundColor ?? Theme.of(context).colorScheme.primary,
//           width: 1.5,
//         ),
//         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//       )
//           : BoxDecoration(
//         color: backgroundColor ?? Theme.of(context).colorScheme.primary,
//         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//       ),
//       child: IconButton(
//         onPressed: onPressed,
//         icon: Icon(
//           icon,
//           size: iconSize,
//           color: iconColor ??
//               (isOutlined
//                   ? backgroundColor ?? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.onPrimary),
//         ),
//         padding: EdgeInsets.zero,
//         splashRadius: size / 2,
//       ),
//     );
//   }
// }