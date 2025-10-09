import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Static widget displaying CC BY-SA 4.0 license notice for image uploads
///
/// This widget informs users that by uploading images, they agree to release
/// them under the CC BY-SA 4.0 license. The license name is clickable and
/// opens the Creative Commons license page.
///
/// Being a separate widget allows Flutter to optimize rendering since
/// this content never changes.
class LicenseInfoWidget extends StatelessWidget {
  const LicenseInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                children: [
                  TextSpan(text: i18n.imageDetailsLicenseNotice),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () async {
                        final url = Uri.parse('https://creativecommons.org/licenses/by-sa/4.0/');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text(
                        i18n.imageDetailsLicenseNoticeLinkToLicense,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
