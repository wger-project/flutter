/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wger/core/dashboard.dart';
import 'package:wger/core/material.dart';
import 'package:wger/features/gallery/screens/gallery_screen.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/features/nutrition/screens/nutritional_plans_screen.dart';
import 'package:wger/features/routines/screens/routine_list_screen.dart';
import 'package:wger/features/weight/screens/weight_screen.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class HomeTabsScreen extends ConsumerStatefulWidget {
  const HomeTabsScreen({super.key});

  static const routeName = '/dashboard2';

  @override
  ConsumerState<HomeTabsScreen> createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends ConsumerState<HomeTabsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isWideScreen = false;

  @override
  void initState() {
    super.initState();

    // Pull any new readings from Apple Health / Health Connect once the app is
    // open. The sync is a no-op unless the user enabled it in the settings.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(healthSyncProvider.notifier).syncOnAppOpen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final size = MediaQuery.sizeOf(context);
    _isWideScreen = size.width > MATERIAL_XS_BREAKPOINT;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _screenList = [
    const DashboardScreen(),
    const RoutineListScreen(),
    const NutritionalPlansScreen(),
    const WeightScreen(),
    const GalleryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home),
        label: AppLocalizations.of(context).labelDashboard,
      ),
      NavigationDestination(
        icon: const Icon(Icons.fitness_center),
        label: AppLocalizations.of(context).labelBottomNavWorkout,
      ),
      NavigationDestination(
        icon: const Icon(Icons.restaurant),
        label: AppLocalizations.of(context).labelBottomNavNutrition,
      ),
      NavigationDestination(
        icon: const FaIcon(FontAwesomeIcons.weightScale, size: 20),
        label: AppLocalizations.of(context).weight,
      ),
      NavigationDestination(
        icon: const Icon(Icons.photo_library),
        label: AppLocalizations.of(context).gallery,
      ),
    ];

    /// Navigation bar for narrow screens
    Widget getNavigationBar() {
      return NavigationBar(
        destinations: destinations,
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      );
    }

    /// Navigation rail for wide screens
    Widget getNavigationRail() {
      return NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelType: NavigationRailLabelType.all,
        scrollable: true,
        destinations: destinations
            .map(
              (d) => NavigationRailDestination(
                icon: d.icon,
                label: Text(d.label),
              ),
            )
            .toList(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          if (_isWideScreen) getNavigationRail(),
          Expanded(child: _screenList.elementAt(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: _isWideScreen ? null : getNavigationBar(),
    );
  }
}
