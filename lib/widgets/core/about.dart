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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/providers/auth.dart';

class AboutEntry extends StatelessWidget {
  final String url;
  final String title;
  final String content;
  final Icon icon;

  const AboutEntry({
    required this.title,
    required this.content,
    required this.url,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          Text(url, style: const TextStyle(color: Colors.blue)),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () async => launchURL(url, context),
    );
  }
}

class AboutPage extends StatelessWidget {
  static String routeName = '/AboutPage';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).aboutPageTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 0.125 * deviceSize.height,
              // color: Colors.red,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: 75),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Wger',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('App: ${authProvider.applicationVersion!.version}\n'
                          'Server: ${authProvider.serverVersion}'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 0.225 * deviceSize.width),
              child: Text(
                '\u{a9} 2020 - ${today.year} contributors',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            SizedBox(height: 0.025 * deviceSize.height),
            Text(
              AppLocalizations.of(context).aboutDescription,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            AboutEntry(
              title: AppLocalizations.of(context).aboutSourceTitle,
              content: AppLocalizations.of(context).aboutSourceText,
              url: 'https://github.com/wger-project',
              icon: const Icon(Icons.code),
            ),
            const SizedBox(height: 10),
            AboutEntry(
              title: AppLocalizations.of(context).aboutBugsTitle,
              content: AppLocalizations.of(context).aboutBugsText,
              url: 'https://github.com/wger-project/flutter/issues/new/choose',
              icon: const Icon(Icons.bug_report),
            ),
            const SizedBox(height: 10),
            AboutEntry(
              title: AppLocalizations.of(context).aboutContactUsTitle,
              content: AppLocalizations.of(context).aboutContactUsText,
              url: 'https://discord.gg/rPWFv6W',
              icon: const Icon(FontAwesomeIcons.discord),
            ),
            const SizedBox(height: 10),
            AboutEntry(
              title: AppLocalizations.of(context).aboutMastodonTitle,
              content: AppLocalizations.of(context).aboutMastodonText,
              url: 'https://fosstodon.org/@wger',
              icon: const Icon(FontAwesomeIcons.mastodon),
            ),
            const SizedBox(height: 10),
            AboutEntry(
              title: AppLocalizations.of(context).aboutTranslationTitle,
              content: AppLocalizations.of(context).aboutTranslationText,
              url: 'https://hosted.weblate.org/engage/wger',
              icon: const Icon(Icons.translate),
            ),
            const SizedBox(height: 10),
            AboutEntry(
              title: AppLocalizations.of(context).aboutDonateTitle,
              content: AppLocalizations.of(context).aboutDonateText,
              url: 'https://www.buymeacoffee.com/wger',
              icon: const Icon(FontAwesomeIcons.moneyBill1),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('View Licenses'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'wger',
                  applicationVersion: 'App: ${authProvider.applicationVersion!.version}\n'
                      'Server: ${authProvider.serverVersion}',
                  applicationLegalese: '\u{a9} 2020 - 2021 contributors',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.asset('assets/images/logo.png', width: 60),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
