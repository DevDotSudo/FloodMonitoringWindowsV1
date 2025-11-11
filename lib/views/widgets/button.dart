import 'package:flutter/material.dart';
import 'package:flood_monitoring/constants/app_colors.dart'; 

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double elevation;
  final bool isOutlined;
  final TextStyle? textStyle;
  final Widget? icon;
  final MainAxisAlignment iconAlignment;
  final double gapBetweenIconAndText;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 48.0, 
    this.color = AppColors.primary, 
    this.textColor = Colors.white, 
    this.borderColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0), 
    this.elevation = 2.0, 
    this.isOutlined = false,
    this.textStyle,
    this.icon,
    this.iconAlignment = MainAxisAlignment.center,
    this.gapBetweenIconAndText = 8.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor, 
            side: BorderSide(color: borderColor ?? color, width: 1.5), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: elevation,
            minimumSize: Size(width ?? double.infinity, height!),
            textStyle: textStyle ??
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: isDisabled ? color.withOpacity(0.6) : color, 
            foregroundColor: isDisabled ? textColor.withOpacity(0.8) : textColor, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: elevation,
            shadowColor: color.withOpacity(0.3), 
            minimumSize: Size(width ?? double.infinity, height!),
            textStyle: textStyle ??
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          );

    Widget buildContent() {
      if (isLoading) {
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor), 
          ),
        );
      }

      if (icon == null) {
        return Text(text, textAlign: TextAlign.center);
      }

      return Row(
        mainAxisSize: MainAxisSize.min, 
        mainAxisAlignment: iconAlignment,
        children: [
          icon!,
          SizedBox(width: gapBetweenIconAndText),
          Text(text),
        ],
      );
    }

    
    final Widget buttonWidget = isOutlined
        ? OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: buttonStyle,
            child: buildContent(),
          )
        : ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: buttonStyle,
            child: buildContent(),
          );

    
    
    if (width != null && width != double.infinity) {
      return SizedBox(
        width: width,
        height: height,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}