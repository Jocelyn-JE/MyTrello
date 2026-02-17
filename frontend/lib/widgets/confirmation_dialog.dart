import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';

/// A reusable confirmation dialog for destructive actions.
///
/// This widget provides a consistent UI for confirmation dialogs across the app,
/// with a cancel button and a destructive action button (typically red/error colored).
class ConfirmationDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The content/message of the dialog
  final String content;

  /// The text for the confirm button (defaults to localized "Delete")
  final String? confirmText;

  /// The text for the cancel button (defaults to localized "Cancel")
  final String? cancelText;

  /// Whether this is a destructive action (uses error color). Defaults to true.
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.isDestructive = true,
  });

  /// Shows a confirmation dialog and returns true if confirmed, false/null otherwise
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText ?? l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(confirmText ?? l10n.delete),
        ),
      ],
    );
  }
}
