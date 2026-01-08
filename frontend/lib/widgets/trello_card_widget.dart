import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/board_permissions_service.dart';
import 'package:frontend/user_search_dialog.dart';
import 'package:frontend/websocket/websocket.dart';

class TrelloCardWidget extends StatefulWidget {
  final TrelloCard card;
  final bool isDraggable;

  const TrelloCardWidget({
    super.key,
    required this.card,
    this.isDraggable = false,
  });

  @override
  State<TrelloCardWidget> createState() => _TrelloCardWidgetState();
}

class _TrelloCardWidgetState extends State<TrelloCardWidget> {
  TextEditingController? _titleController;
  TextEditingController? _contentController;
  FocusNode? _contentFocusNode;
  String _previousContent = '';

  @override
  void initState() {
    super.initState();
    _previousContent = widget.card.content;

    // Only create controllers if user can edit
    if (BoardPermissionsService.canEdit) {
      _titleController = TextEditingController(text: widget.card.title);
      _contentController = TextEditingController(text: widget.card.content);
      _contentFocusNode = FocusNode();

      _contentFocusNode!.addListener(() {
        if (!_contentFocusNode!.hasFocus) {
          // Save when focus is lost
          _saveContent();
        }
      });
    }
  }

  @override
  void didUpdateWidget(TrelloCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (BoardPermissionsService.canEdit) {
      if (oldWidget.card.title != widget.card.title) {
        _titleController?.text = widget.card.title;
      }
      if (oldWidget.card.content != widget.card.content) {
        _contentController?.text = widget.card.content;
        _previousContent = widget.card.content;
      }
    }
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _contentController?.dispose();
    _contentFocusNode?.dispose();
    super.dispose();
  }

  void _saveContent() {
    if (_contentController == null) return;
    final newContent = _contentController!.text.trim();

    // If content is empty, revert to previous content
    if (newContent.isEmpty) {
      _contentController!.text = _previousContent;
      return;
    }

    if (newContent != _previousContent) {
      WebsocketService.updateCard(cardId: widget.card.id, content: newContent);
      _previousContent = newContent;
    }
  }

  void _saveTitle() {
    if (_titleController == null) return;
    final newTitle = _titleController!.text;
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

  Future<TrelloUser?> _showAssignUsersDialog(
    List<TrelloUser> alreadyAssigned,
  ) async {
    // Implementation of user assignment dialog goes here
    // This is a placeholder for demonstration purposes
    return await showDialog(
      context: context,
      builder: (context) => UserSearchDialog(
        excludedUserIds: alreadyAssigned.map((u) => u.id).toList(),
        ownerId: '', // No owner filtering in this context
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = BoardPermissionsService.canEdit;

    final cardWidget = Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canEdit)
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
                        )
                      else
                        Text(
                          widget.card.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 4),
                      if (canEdit)
                        TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Card description',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                        )
                      else
                        Text(
                          widget.card.content,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
                if (canEdit)
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
                      const SizedBox(height: 4),
                      IconButton(
                        icon: const Icon(Icons.person_add, size: 18),
                        color: Colors.blue,
                        tooltip: 'Assign users',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final assignedUser = await _showAssignUsersDialog(
                            widget.card.assignedUsers,
                          );
                          if (assignedUser != null) {
                            WebsocketService.assignUserToCard(
                              widget.card.id,
                              assignedUser.id,
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
            if (widget.card.assignedUsers.isNotEmpty) ...[
              Divider(height: 12, color: Colors.grey[300]),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.card.assignedUsers.map((user) {
                    return CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          Colors.primaries[Random(
                            user.id.hashCode,
                          ).nextInt(Colors.primaries.length)],
                      child: Text(
                        user.username.isNotEmpty
                            ? user.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Wrap with Draggable if editing is enabled and isDraggable is true
    if (canEdit && widget.isDraggable) {
      return Draggable<TrelloCard>(
        data: widget.card,
        feedback: SizedBox(
          width: 278,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.card.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.card.content,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: cardWidget),
        child: cardWidget,
      );
    }
    return cardWidget;
  }
}
