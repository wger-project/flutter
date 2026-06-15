/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/auth/server_field.dart';

/// Opens the advanced bottom sheet (server + sign-in-method selection).
///
/// [onChanged] fires whenever the user picks a different option so the
/// parent screen can reflect the choice live behind the sheet.
Future<void> showAdvancedSheet({
  required BuildContext context,
  required bool initialHideCustomServer,
  required bool initialUsePassword,
  required bool loginMode,
  required TextEditingController serverUrlController,
  required void Function(bool hideCustomServer, bool usePassword) onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AdvancedSheet(
      initialHideCustomServer: initialHideCustomServer,
      initialUsePassword: initialUsePassword,
      loginMode: loginMode,
      serverUrlController: serverUrlController,
      onChanged: onChanged,
    ),
  );
}

class AdvancedSheet extends StatefulWidget {
  final bool initialHideCustomServer;
  final bool initialUsePassword;
  final bool loginMode;
  final TextEditingController serverUrlController;
  final void Function(bool hideCustomServer, bool usePassword) onChanged;

  const AdvancedSheet({
    required this.initialHideCustomServer,
    required this.initialUsePassword,
    required this.loginMode,
    required this.serverUrlController,
    required this.onChanged,
    super.key,
  });

  @override
  State<AdvancedSheet> createState() => _AdvancedSheetState();
}

class _AdvancedSheetState extends State<AdvancedSheet> {
  late bool _hideCustomServer;
  late bool _usePassword;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _hideCustomServer = widget.initialHideCustomServer;
    _usePassword = widget.initialUsePassword;
  }

  void _set(VoidCallback change) {
    setState(change);
    widget.onChanged(_hideCustomServer, _usePassword);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final defaultServerName = Uri.parse(DEFAULT_SERVER_PROD).host;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          0,
          22,
          26 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i18n.advanced, style: theme.textTheme.titleLarge),
                        Text(
                          i18n.advancedSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('advancedCloseButton'),
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              _SectionLabel(text: i18n.serverSectionLabel),
              _OptionRow(
                icon: Icons.public_outlined,
                title: defaultServerName,
                detail: i18n.serverOptionDefaultDetail,
                selected: _hideCustomServer,
                onTap: () => _set(() => _hideCustomServer = true),
              ),
              _OptionRow(
                icon: Icons.dns_outlined,
                title: i18n.serverOptionSelfHostedTitle,
                detail: i18n.serverOptionSelfHostedDetail,
                selected: !_hideCustomServer,
                onTap: () => _set(() => _hideCustomServer = false),
              ),
              if (!_hideCustomServer)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: ServerField(controller: widget.serverUrlController),
                ),
              if (widget.loginMode) ...[
                _SectionLabel(text: i18n.signInMethodSectionLabel),
                _OptionRow(
                  icon: Icons.person_outline,
                  title: i18n.authOptionPasswordTitle,
                  selected: _usePassword,
                  onTap: () => _set(() => _usePassword = true),
                ),
                _OptionRow(
                  icon: Icons.key_outlined,
                  title: i18n.refreshToken,
                  detail: i18n.tokenSubtitle,
                  selected: !_usePassword,
                  onTap: () => _set(() => _usePassword = false),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  key: const Key('advancedDoneButton'),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? true) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    i18n.done,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.title,
    this.detail,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? scheme.primary : scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: selected ? null : Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected ? scheme.onPrimary : scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleSmall),
                      const SizedBox(height: 2),
                      if (detail != null)
                        Text(
                          detail!,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? scheme.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outline,
                      width: 2,
                    ),
                  ),
                  child: selected ? Icon(Icons.check, size: 12, color: scheme.onPrimary) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
