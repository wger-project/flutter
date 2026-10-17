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

import 'package:material_ui/material_ui.dart';
import 'package:wger/features/auth/widgets/auth_card.dart';
import 'package:wger/theme/theme.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen();

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
    final scheme = Theme.of(context).colorScheme;
    // The banner matches the gym's black and yellow logo in both modes
    const bannerColor = ctBlack;
    const onBannerColor = ctYellow;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 0.55 * deviceSize.height,
              color: bannerColor,
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 0.15 * deviceSize.height),
                  const Image(
                    image: AssetImage('assets/images/logo-white.png'),
                    width: 130,
                    height: 130,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 94.0,
                    ),
                    child: Text(
                      'CT da Vila',
                      style: TextStyle(
                        color: onBannerColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.025 * deviceSize.height),
                  const Flexible(child: AuthCard()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
