import 'package:flutter/material.dart';
import 'package:frontend/websocket/websocket.dart';

class TrelloCardWidget extends StatefulWidget {
  final TrelloCard card;

  const TrelloCardWidget({super.key, required this.card});

  @override
  State<TrelloCardWidget> createState() => _TrelloCardWidgetState();
}

class _TrelloCardWidgetState extends State<TrelloCardWidget> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();
  String _previousContent = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _contentController = TextEditingController(text: widget.card.content);
    _previousContent = widget.card.content;

    _contentFocusNode.addListener(() {
      if (!_contentFocusNode.hasFocus) {
        // Save when focus is lost
        _saveContent();
      }
    });
  }

  @override
  void didUpdateWidget(TrelloCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.title != widget.card.title) {
      _titleController.text = widget.card.title;
    }
    if (oldWidget.card.content != widget.card.content) {
      _contentController.text = widget.card.content;
      _previousContent = widget.card.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _saveContent() {
    final newContent = _contentController.text.trim();

    // If content is empty, revert to previous content
    if (newContent.isEmpty) {
      _contentController.text = _previousContent;
      return;
    }

    if (newContent != _previousContent) {
      WebsocketService.updateCard(cardId: widget.card.id, content: newContent);
      _previousContent = newContent;
    }
  }

  void _saveTitle() {
    final newTitle = _titleController.text;
    if (newTitle.isNotEmpty && newTitle != widget.card.title) {
      WebsocketService.updateCard(cardId: widget.card.id, title: newTitle);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text(
          'Are you sure you want to delete "${widget.card.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      WebsocketService.deleteCard(widget.card.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Card title',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    onSubmitted: (_) => _saveTitle(),
                    onEditingComplete: () {
                      _saveTitle();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Card description',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                  ),
                  if (widget.card.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.card.dueDate!.month}/${widget.card.dueDate!.day}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  color: Colors.red,
                  tooltip: 'Delete card',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _confirmDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
