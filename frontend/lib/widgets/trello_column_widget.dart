import 'package:flutter/material.dart';
import 'package:frontend/websocket/websocket.dart';
import 'package:frontend/widgets/trello_card_widget.dart';

class TrelloColumnWidget extends StatefulWidget {
  final TrelloColumn column;
  final VoidCallback onAddCard;

  const TrelloColumnWidget({
    super.key,
    required this.column,
    required this.onAddCard,
  });

  @override
  State<TrelloColumnWidget> createState() => _TrelloColumnWidgetState();
}

class _TrelloColumnWidgetState extends State<TrelloColumnWidget> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.column.title);
  }

  @override
  void didUpdateWidget(TrelloColumnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.column.title != widget.column.title) {
      _titleController.text = widget.column.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTitle() {
    final newTitle = _titleController.text;
    if (newTitle.isNotEmpty && newTitle != widget.column.title) {
      WebsocketService.renameColumn(widget.column.id, newTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Column title',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                onSubmitted: (_) => _saveTitle(),
                onEditingComplete: () {
                  _saveTitle();
                  FocusScope.of(context).unfocus();
                },
              ),
              const Divider(),
              // Cards list
              Expanded(
                child: widget.column.cards.isEmpty
                    ? const Center(
                        child: Text(
                          'No cards',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.column.cards.length,
                        itemBuilder: (context, index) {
                          final card = widget.column.cards[index];
                          return TrelloCardWidget(card: card);
                        },
                      ),
              ),
              const SizedBox(height: 8),
              // Add card button
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade100,
                ),
                onPressed: widget.onAddCard,
              ),
              const SizedBox(height: 8),
              // Delete column button
              IconButton(
                color: Colors.red,
                icon: const Icon(Icons.delete),
                tooltip: 'Delete column',
                onPressed: () {
                  WebsocketService.deleteColumn(widget.column.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
