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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/providers/auth.dart';

class WgerAboutListTile extends StatelessWidget {
  void _launchURL(String url, BuildContext context) async {
    await canLaunch(url)
        ? await launch(url)
        : ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open $url.")),
          );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AboutListTile(
      //dense: true,
      icon: Icon(Icons.info),
      applicationName: 'wger',
      applicationVersion: 'App: ${authProvider.applicationVersion!.version}\n'
          'Server: ${authProvider.serverVersion}',
      applicationLegalese: '\u{a9} 2020 - 2021 contributors',
      applicationIcon: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Image.asset(
          'assets/images/logo.png',
          width: 60,
        ),
      ),

      aboutBoxChildren: [
        SizedBox(height: 10),
        Text(AppLocalizations.of(context).aboutDescription),
        SizedBox(height: 20),
        ListTile(
          leading: Icon(Icons.code),
          title: Text(AppLocalizations.of(context).aboutSourceTitle),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).aboutSourceText),
              Text(
                'https://github.com/wger-project',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          onTap: () async =>
              _launchURL("https://github.com/wger-project", context),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.bug_report),
          title: Text(AppLocalizations.of(context).aboutBugsTitle),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).aboutBugsText),
              Text(
                'https://github.com/wger-project/flutter/issues/new/choose',
                style: TextStyle(color: Colors.blue),
              )
            ],
          ),
          contentPadding: EdgeInsets.zero,
          onTap: () async => _launchURL(
              'https://github.com/wger-project/flutter/issues/new/choose',
              context),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.chat),
          title: Text(AppLocalizations.of(context).aboutContactUsTitle),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).aboutContactUsText),
              Text(
                'https://discord.gg/rPWFv6W',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          onTap: () async => _launchURL('https://discord.gg/rPWFv6W', context),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.translate),
          title: Text(AppLocalizations.of(context).aboutTranslationTitle),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).aboutTranslationText),
              Text(
                'https://hosted.weblate.org/engage/wger/',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          onTap: () async =>
              _launchURL('https://hosted.weblate.org/engage/wger/', context),
        ),
      ],
    );
  }
}
