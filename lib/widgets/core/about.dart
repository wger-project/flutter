/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth.dart';

class AboutPage extends StatelessWidget {
  static String routeName = '/AboutPage';

  static String githubProjectUrl = 'https://github.com/wger-project';
  static String githubIssuesUrl = 'https://github.com/wger-project/flutter/issues/new/choose';
  static String discordUrl = 'https://discord.gg/rPWFv6W';
  static String mastodonUrl = 'https://fosstodon.org/@wger';
  static String weblateUrl = 'https://hosted.weblate.org/engage/wger';
  static String buyMeACoffeeUrl = 'https://buymeacoffee.com/wger';
  static String liberapayUrl = 'https://liberapay.com/wger';
  static String githubSponsorsUrl = 'https://github.com/sponsors/wger-project';

  const AboutPage({super.key});

  Widget _buildSectionSpacer() => const SizedBox(height: 24.0);

  // Helper function for section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final i18n = AppLocalizations.of(context);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(i18n.aboutPageTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 60,
                  semanticLabel: 'wger logo',
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'wger',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'App: ${authProvider.applicationVersion?.version ?? 'N/A'}\n'
                      'Server: ${authProvider.serverVersion ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '\u{a9} ${today.year} wger contributors',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            _buildSectionSpacer(),
            _buildSectionHeader(context, i18n.aboutWhySupportTitle),
            Text(i18n.aboutDescription),

            _buildSectionSpacer(),
            _buildSectionHeader(context, i18n.aboutContributeTitle),
            Text(i18n.aboutContributeText),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(i18n.aboutBugsListTitle),
              contentPadding: EdgeInsets.zero,
              onTap: () => launchURL(githubIssuesUrl, context),
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(i18n.aboutTranslationListTitle),
              contentPadding: EdgeInsets.zero,
              onTap: () => launchURL(weblateUrl, context),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(i18n.aboutSourceListTitle),
              contentPadding: EdgeInsets.zero,
              onTap: () => launchURL(githubProjectUrl, context),
            ),

            _buildSectionSpacer(),
            _buildSectionHeader(context, i18n.aboutDonateTitle),
            Text(i18n.aboutDonateText),
            const SizedBox(height: 15),
            // Using Wrap for buttons to handle different screen sizes potentially
            Center(
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const FaIcon(FontAwesomeIcons.mugHot, size: 18),
                    label: const Text('Buy Me A Coffee'),
                    onPressed: () => launchURL(buyMeACoffeeUrl, context),
                  ),
                  ElevatedButton.icon(
                    icon: const FaIcon(FontAwesomeIcons.solidHeart, size: 18),
                    label: const Text('Liberapay'),
                    onPressed: () => launchURL(liberapayUrl, context),
                  ),
                  ElevatedButton.icon(
                    icon: const FaIcon(FontAwesomeIcons.github, size: 18),
                    label: const Text('GitHub Sponsors'),
                    onPressed: () => launchURL(githubSponsorsUrl, context),
                  ),
                ],
              ),
            ),

            _buildSectionSpacer(),
            _buildSectionHeader(context, i18n.aboutJoinCommunityTitle),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.discord),
              title: Text(i18n.aboutContactUsListTitle),
              contentPadding: EdgeInsets.zero,
              onTap: () => launchURL(discordUrl, context),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.mastodon),
              title: Text(i18n.aboutMastodonListTitle),
              contentPadding: EdgeInsets.zero,
              onTap: () => launchURL(mastodonUrl, context),
            ),

            _buildSectionSpacer(),
            _buildSectionHeader(context, i18n.others),

            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('View Licenses'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'wger',
                  applicationVersion: 'App: ${authProvider.applicationVersion?.version ?? 'N/A'} '
                      'Server: ${authProvider.serverVersion ?? 'N/A'}',
                  applicationLegalese: '\u{a9} ${today.year} wger contributors',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      semanticLabel: 'wger logo',
                    ),
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
