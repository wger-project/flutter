/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/core/about.dart';
import 'package:wger/widgets/core/settings.dart';
import 'package:wger/widgets/user/forms.dart';

/// Standard text style for AppBar titles
const kAppBarTitleStyle = TextStyle(
  fontFamily: 'Inter',
  fontVariations: [FontVariation('wght', 800)],
  fontSize: 22,
);

/// Returns the blur effect widget used in app bars
Widget buildAppBarBlurBackground(BuildContext context) {
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
      ),
    ),
  );
}

/// Returns the padding needed for body content when using extendBodyBehindAppBar
/// Set [includeToolbarHeight] to false for widgets that handle toolbar offset separately
EdgeInsets getAppBarBodyPadding(
  BuildContext context, {
  double left = 0,
  double right = 0,
  double bottom = 0,
  double extraTop = 0,
  bool includeToolbarHeight = true,
}) {
  return EdgeInsets.only(
    top:
        MediaQuery.of(context).padding.top + (includeToolbarHeight ? kToolbarHeight : 0) + extraTop,
    left: left,
    right: right,
    bottom: bottom,
  );
}

/// A reusable AppBar widget with the standard wger styling.
/// Use this for screens that need a simple title-only app bar.
class WgerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const WgerAppBar(this.title, {super.key, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      title: Text(
        title,
        style: kAppBarTitleStyle.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: buildAppBarBlurBackground(context),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String _title;

  const MainAppBar(this._title);

  /// Show adaptive menu based on screen size
  void _showMenu(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > MATERIAL_XS_BREAKPOINT;

    if (isWideScreen) {
      _showPopupMenu(context);
    } else {
      _showBottomSheetMenu(context);
    }
  }

  /// Modern popup menu for desktop/wide screens
  void _showPopupMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).userProfile),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings, size: 20),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).settingsTitle),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'about',
          child: Row(
            children: [
              const Icon(Icons.info, size: 20),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).aboutPageTitle),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.exit_to_app, size: 20),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).logout),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (context.mounted) {
        _handleMenuSelection(context, value);
      }
    });
  }

  /// Modern bottom sheet menu for mobile/narrow screens
  void _showBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Menu header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          context.read<UserProvider>().profile?.username ??
                              AppLocalizations.of(context).optionsLabel,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Menu items
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppLocalizations.of(context).userProfile),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleMenuSelection(context, 'profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(AppLocalizations.of(context).settingsTitle),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleMenuSelection(context, 'settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(AppLocalizations.of(context).aboutPageTitle),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleMenuSelection(context, 'about');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: Text(AppLocalizations.of(context).logout),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleMenuSelection(context, 'logout');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handle menu item selection
  void _handleMenuSelection(BuildContext context, String? value) {
    if (value == null) return;

    switch (value) {
      case 'profile':
        Navigator.pushNamed(
          context,
          FormScreen.routeName,
          arguments: FormScreenArguments(
            AppLocalizations.of(context).userProfile,
            UserProfileForm(
              context.read<UserProvider>().profile!,
            ),
          ),
        );
        break;
      case 'settings':
        Navigator.of(context).pushNamed(SettingsPage.routeName);
        break;
      case 'about':
        Navigator.of(context).pushNamed(AboutPage.routeName);
        break;
      case 'logout':
        context.read<AuthProvider>().logout();
        context.read<RoutinesProvider>().clear();
        context.read<NutritionPlansProvider>().clear();
        context.read<BodyWeightProvider>().clear();
        context.read<GalleryProvider>().clear();
        context.read<UserProvider>().clear();
        Navigator.of(context).pushReplacementNamed('/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      title: Text(
        _title,
        style: kAppBarTitleStyle,
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: buildAppBarBlurBackground(context),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: IconButton(
              icon: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              tooltip: AppLocalizations.of(context).optionsLabel,
              onPressed: () => _showMenu(context),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// App bar that only displays a title
class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String _title;

  const EmptyAppBar(this._title);

  @override
  Widget build(BuildContext context) {
    return WgerAppBar(_title);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
