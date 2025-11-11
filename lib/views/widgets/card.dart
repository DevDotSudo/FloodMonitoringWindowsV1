import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;
  final double elevation; 

  const CustomCard({
    super.key,
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(20.0),
    this.backgroundColor = Colors.white,
    this.boxShadow,
    this.borderRadius,
    this.border,
    this.elevation = 4.0, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ??
            Border.all(
                color: Colors.grey.withOpacity(0.08),
                width: 0.5),
        boxShadow: boxShadow ?? _createDynamicShadow(elevation), 
      ),
      child: child,
    );
  }
  
  List<BoxShadow> _createDynamicShadow(double currentElevation) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(currentElevation * 0.01), 
        blurRadius: currentElevation * 2.5, 
        spreadRadius: 0,
        offset: Offset(0, currentElevation * 0.8), 
      ),
    ];
  }
}