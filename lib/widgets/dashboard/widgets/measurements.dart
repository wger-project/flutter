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

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/time_range_tab_bar.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/measurements/categories_card.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/forms.dart';

class DashboardMeasurementWidget extends StatefulWidget {
  const DashboardMeasurementWidget();

  @override
  _DashboardMeasurementWidgetState createState() => _DashboardMeasurementWidgetState();
}

class _DashboardMeasurementWidgetState extends State<DashboardMeasurementWidget> {
  int _current = 0;
  final _controller = CarouselSliderController();
  ChartTimeRange _selectedRange = ChartTimeRange.month;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MeasurementProvider>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final items = provider.categories
        .map<Widget>((item) => CategoriesCard(item, timeRange: _selectedRange, showCard: false))
        .toList();
    if (items.isNotEmpty) {
      items.add(_buildAddMoreCard(context, isDarkMode));
    }
    return Consumer<MeasurementProvider>(
      builder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with chevron
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).measurements,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pushNamed(
                            context,
                            MeasurementCategoriesScreen.routeName,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Time range tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TimeRangeTabBar(
                    selectedRange: _selectedRange,
                    onRangeChanged: (range) => setState(() => _selectedRange = range),
                  ),
                ),
                const SizedBox(height: 16),
                // Content
                Column(
                  children: [
                    if (items.isNotEmpty)
                      Column(
                        children: [
                          CarouselSlider(
                            items: items,
                            carouselController: _controller,
                            options: CarouselOptions(
                              autoPlay: false,
                              enlargeCenterPage: false,
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              aspectRatio: 1.35,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                            ),
                          ),
                          // Line segment indicators
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Row(
                              children: items.asMap().entries.map((entry) {
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _controller.animateToPage(entry.key),
                                    child: Container(
                                      height: 3,
                                      margin: EdgeInsets.only(
                                        right: entry.key < items.length - 1 ? 4 : 0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: _current == entry.key
                                            ? wgerAccentColor
                                            : (isDarkMode
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: NothingFound(
                          AppLocalizations.of(context).noMeasurementEntries,
                          AppLocalizations.of(context).newEntry,
                          MeasurementCategoryForm(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreCard(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Measuring tape icon
          Image.asset(
            'assets/icons/measuring-tape.png',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            AppLocalizations.of(context).moreMeasurementEntries,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Add button
          Material(
            color: wgerAccentColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).newEntry,
                    MeasurementCategoryForm(),
                    hasListView: true,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).newEntry,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
