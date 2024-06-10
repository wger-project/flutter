import 'package:flutter/material.dart';

/// NutritionTile is similar to a non-interactive ListTile,
/// but uses a fixed, easy to understand layout.
/// any trailing value is overlayed over the title & subtitle, on the right
/// as to not disturb the overall layout
class NutritionTile extends StatelessWidget {
  final Widget? leading; // will always be constrained to 40px wide
  final double vPadding;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  const NutritionTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.vPadding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: vPadding),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40, maxWidth: 40),
            child: leading ?? const SizedBox(width: 40),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    if (title != null) title!,
                    if (subtitle != null) subtitle!,
                  ],
                ),
                if (trailing != null) Align(alignment: Alignment.centerRight, child: trailing!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
