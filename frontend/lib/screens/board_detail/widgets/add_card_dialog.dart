import 'package:flutter/material.dart';
import 'package:frontend/services/websocket/websocket_service.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AddCardDialog extends StatefulWidget {
  final String columnId;
  const AddCardDialog({super.key, required this.columnId});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final TextEditingController _cardTitleController = TextEditingController();
  final TextEditingController _cardDescriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addCardDialog),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _cardTitleController,
            decoration: InputDecoration(
              labelText: l10n.title,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cardDescriptionController,
            decoration: InputDecoration(
              labelText: l10n.description,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _cardTitleController.text.trim();
            final content = _cardDescriptionController.text.trim();
            if (title.isNotEmpty && content.isNotEmpty) {
              WebsocketService.createCard(
                columnId: widget.columnId,
                title: title,
                content: content,
              );
              Navigator.pop(context);
            }
          },
          child: Text(l10n.add),
        ),
      ],
    );
  }
}
