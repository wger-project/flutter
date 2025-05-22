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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/measurements/categories_card.dart';
import 'package:wger/widgets/measurements/forms.dart';

class DashboardMeasurementWidget extends StatefulWidget {
  const DashboardMeasurementWidget();

  @override
  _DashboardMeasurementWidgetState createState() => _DashboardMeasurementWidgetState();
}

class _DashboardMeasurementWidgetState extends State<DashboardMeasurementWidget> {
  int _current = 0;
  final _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MeasurementProvider>(context, listen: false);

    final items =
        provider.categories.map<Widget>((item) => CategoriesCard(item, elevation: 0)).toList();
    if (items.isNotEmpty) {
      items.add(
        NothingFound(
          AppLocalizations.of(context).moreMeasurementEntries,
          AppLocalizations.of(context).newEntry,
          MeasurementCategoryForm(),
        ),
      );
    }
    return Consumer<MeasurementProvider>(
      builder: (context, _, __) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context).measurements,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              leading: FaIcon(
                FontAwesomeIcons.chartLine,
                color: Theme.of(context).textTheme.headlineSmall!.color,
              ),
              // TODO: this icon feels out of place and inconsistent with all
              // other dashboard widgets.
              // maybe we should just add a "Go to all" at the bottom of the widget
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => Navigator.pushNamed(
                  context,
                  MeasurementCategoriesScreen.routeName,
                ),
              ),
            ),
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
                          aspectRatio: 1.1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Theme.of(context).textTheme.headlineSmall!.color!.withOpacity(
                                            _current == entry.key ? 0.9 : 0.4,
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
                  NothingFound(
                    AppLocalizations.of(context).noMeasurementEntries,
                    AppLocalizations.of(context).newEntry,
                    MeasurementCategoryForm(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
