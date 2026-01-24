import 'package:flutter/material.dart';
import 'package:frontend/services/websocket/websocket_service.dart';

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
    return AlertDialog(
      title: const Text('Add Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _cardTitleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cardDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
          child: const Text('Add'),
        ),
      ],
    );
  }
}
