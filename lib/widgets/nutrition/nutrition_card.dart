/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/theme/theme.dart';

/// Semicircular progress indicator for nutrition goals
class NutritionGoalsWidget extends StatelessWidget {
  const NutritionGoalsWidget({
    super.key,
    required NutritionalPlan nutritionalPlan,
    this.onLogIngredient,
    this.onLogMeal,
  }) : _nutritionalPlan = nutritionalPlan;

  final NutritionalPlan _nutritionalPlan;
  final VoidCallback? onLogIngredient;
  final VoidCallback? onLogMeal;

  @override
  Widget build(BuildContext context) {
    final plan = _nutritionalPlan;
    final goals = plan.nutritionalGoals;
    final today = plan.loggedNutritionalValuesToday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Column(
        children: [
          // Large calorie semicircle with action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (onLogIngredient != null)
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.06)
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.black.withOpacity(0.08)
                                : Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onLogIngredient,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/icons/apple.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: _buildLargeSemicircle(
                  context,
                  label: AppLocalizations.of(context).energy,
                  value: today.energy,
                  goal: goals.energy,
                  unit: AppLocalizations.of(context).kcal,
                  color: wgerAccentColor,
                ),
              ),
              if (onLogMeal != null)
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.06)
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.black.withOpacity(0.08)
                                : Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onLogMeal,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/icons/meal.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Three macro semicircles in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildSmallSemicircle(
                  context,
                  label: AppLocalizations.of(context).protein,
                  value: today.protein,
                  goal: goals.protein,
                  unit: AppLocalizations.of(context).g,
                  color: wgerAccentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallSemicircle(
                  context,
                  label: AppLocalizations.of(context).carbohydrates,
                  value: today.carbohydrates,
                  goal: goals.carbohydrates,
                  unit: AppLocalizations.of(context).g,
                  color: wgerAccentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallSemicircle(
                  context,
                  label: AppLocalizations.of(context).fat,
                  value: today.fat,
                  goal: goals.fat,
                  unit: AppLocalizations.of(context).g,
                  color: wgerAccentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeSemicircle(
    BuildContext context, {
    required String label,
    required double value,
    required double? goal,
    required String unit,
    required Color color,
  }) {
    final hasGoal = goal != null && goal > 0;
    final progress = hasGoal ? (value / goal).clamp(0.0, 1.0) : 0.0;
    final isOverGoal = hasGoal && value > goal;
    final displayColor = isOverGoal ? const Color(0xFFEF4444) : color;

    return Column(
      children: [
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: _SemicirclePainter(
              progress: progress,
              color: hasGoal ? displayColor : const Color(0xFFE5E7EB),
              backgroundColor: const Color(0xFFF3F4F6),
              strokeWidth: 10,
              isOverGoal: isOverGoal,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasGoal ? displayColor : Colors.grey.shade400,
                      ),
                    ),
                    if (hasGoal)
                      Text(
                        '/ ${goal.toStringAsFixed(0)} $unit',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      )
                    else
                      Text(
                        unit,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: hasGoal ? Colors.grey.shade800 : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallSemicircle(
    BuildContext context, {
    required String label,
    required double value,
    required double? goal,
    required String unit,
    required Color color,
  }) {
    final hasGoal = goal != null && goal > 0;
    final progress = hasGoal ? (value / goal).clamp(0.0, 1.0) : 0.0;
    final isOverGoal = hasGoal && value > goal;
    final displayColor = isOverGoal ? const Color(0xFFEF4444) : color;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: CustomPaint(
            painter: _SemicirclePainter(
              progress: progress,
              color: hasGoal ? displayColor : const Color(0xFFE5E7EB),
              backgroundColor: const Color(0xFFF3F4F6),
              strokeWidth: 6,
              isOverGoal: isOverGoal,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasGoal ? displayColor : Colors.grey.shade400,
                      ),
                    ),
                    if (hasGoal)
                      Text(
                        '/ ${goal.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: hasGoal ? Colors.grey.shade700 : Colors.grey.shade400,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Custom painter for semicircular progress indicator
class _SemicirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final bool isOverGoal;

  _SemicirclePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    this.isOverGoal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height) - strokeWidth / 2;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start at left (180 degrees)
      pi, // Sweep 180 degrees
      false,
      backgroundPaint,
    );

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = isOverGoal
            ? const Color(0xFFEF4444)
            : color // Solid red if over goal
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi, // Start at left (180 degrees)
        pi * progress, // Sweep based on progress
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SemicirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isOverGoal != isOverGoal;
  }
}
