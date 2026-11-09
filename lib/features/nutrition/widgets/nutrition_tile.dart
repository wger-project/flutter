import 'package:material_ui/material_ui.dart';

/// NutritionTile is similar to a non-interactive ListTile,
/// but uses a fixed, easy to understand layout.
class NutritionTile extends StatelessWidget {
  final Widget? leading; // always constrained to 40px wide
  final double vPadding;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final double trailingWidth;

  const NutritionTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.trailingWidth = 20,
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
                ?title,
                ?subtitle,
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: trailingWidth),
            child: trailing ?? const SizedBox(width: 20),
          ),
        ],
      ),
    );
  }
}
