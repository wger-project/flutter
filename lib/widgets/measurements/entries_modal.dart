/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/theme/theme.dart';

import 'edit_modals.dart';

/// Shows a modal bottom sheet with all entries for a measurement category
void showEntriesModal(BuildContext context, MeasurementCategory category) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<MeasurementProvider>(
                          builder: (context, provider, _) {
                            final currentCategory = provider.findCategoryById(category.id!);
                            return Text(
                              '${currentCategory.entries.length} ${AppLocalizations.of(context).entries}',
                              style: TextStyle(
                                color: context.wgerLightGrey,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Category action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      Material(
                        color: wgerAccentColor.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pop(context);
                            showEditCategoryModal(context, category);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: wgerAccentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      Material(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _showDeleteCategoryDialog(context, category),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                height: 24,
              ),
            ),
            // Entries list
            Expanded(
              child: Consumer<MeasurementProvider>(
                builder: (context, provider, _) {
                  final currentCategory = provider.findCategoryById(category.id!);
                  final entries = currentCategory.entries;

                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: wgerAccentColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.straighten_outlined,
                              size: 48,
                              color: wgerAccentColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).noMeasurementEntries,
                            style: TextStyle(
                              color: context.wgerLightGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _EntryTile(
                        entry: entry,
                        category: currentCategory,
                        isDarkMode: isDarkMode,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showDeleteCategoryDialog(BuildContext context, MeasurementCategory category) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(AppLocalizations.of(context).delete),
      content: Text(AppLocalizations.of(context).confirmDelete(category.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
            style: TextStyle(color: context.wgerLightGrey),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            try {
              await Provider.of<MeasurementProvider>(
                context,
                listen: false,
              ).deleteCategory(category.id!);
              if (context.mounted) {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Close modal
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).successfullyDeleted,
                      textAlign: TextAlign.center,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            } catch (error) {
              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).anErrorOccurred,
                      textAlign: TextAlign.center,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
          child: Text(
            AppLocalizations.of(context).delete,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );
}

class _EntryTile extends StatelessWidget {
  final MeasurementEntry entry;
  final MeasurementCategory category;
  final bool isDarkMode;

  const _EntryTile({
    required this.entry,
    required this.category,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Value indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: wgerAccentColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        numberFormat.format(entry.value),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.unit,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: context.wgerLightGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(entry.date),
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                Material(
                  color: wgerAccentColor.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => showEditEntryModal(context, category, entry),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: wgerAccentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                Material(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showDeleteEntryDialog(context, entry),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteEntryDialog(BuildContext context, MeasurementEntry entry) {
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context).delete),
        content: Text(
          AppLocalizations.of(context).confirmDelete(
            '${numberFormat.format(entry.value)} ${category.unit} (${dateFormat.format(entry.date)})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              MaterialLocalizations.of(context).cancelButtonLabel,
              style: TextStyle(color: context.wgerLightGrey),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await Provider.of<MeasurementProvider>(
                  context,
                  listen: false,
                ).deleteEntry(entry.id!, entry.category);
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).successfullyDeleted,
                        textAlign: TextAlign.center,
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).anErrorOccurred,
                        textAlign: TextAlign.center,
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
