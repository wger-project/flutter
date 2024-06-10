import 'package:flutter/material.dart';

/// NutritionTile is similar to a non-interactive ListTile,
/// but uses a fixed, easy to understand layout.
class NutritionTile extends StatelessWidget {
  final Widget? leading; // always constrained to 40px wide
  final double vPadding;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing; // always constrained to 20px wide

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
            child: Column(
              children: [
                if (title != null) title!,
                if (subtitle != null) subtitle!,
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 20, maxWidth: 20),
            child: trailing ?? const SizedBox(width: 20),
          ),
        ],
      ),
    );
  }
}
