import 'package:flutter/material.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/screens/board_detail/widgets/assigned_user_avatar.dart';
import 'package:frontend/screens/board_detail/widgets/card_date_picker_dialog.dart';
import 'package:frontend/widgets/confirmation_dialog.dart';
import 'package:frontend/services/board_permissions_service.dart';
import 'package:frontend/services/websocket/websocket_service.dart';
import 'package:frontend/utils/app_config.dart';
import 'package:frontend/widgets/user_search_dialog.dart';
import 'package:intl/intl.dart';
import 'package:frontend/l10n/app_localizations.dart';

class TrelloCardWidget extends StatefulWidget {
  final TrelloCard card;
  final bool isDraggable;
  final String? cardAboveId;
  final String searchQuery;
  final String boardId;

  const TrelloCardWidget({
    super.key,
    required this.card,
    this.cardAboveId,
    this.isDraggable = false,
    this.searchQuery = '',
    required this.boardId,
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.deleteCard,
      content: l10n.deleteCardConfirmation(widget.card.title),
    );

    if (confirmed == true) {
      WebsocketService.deleteCard(widget.card.id);
    }
  }

  Future<TrelloUser?> _showAssignUsersDialog(
    List<TrelloUser> alreadyAssigned,
  ) async {
    // Implementation of user assignment dialog goes here
    return await showDialog(
      context: context,
      builder: (context) => UserSearchDialog(
        excludedUserIds: alreadyAssigned.map((u) => u.id).toList(),
        searchMode: UserSearchMode.boardMembersNotAssignedToCard,
        boardId: widget.boardId,
        cardId: widget.card.id,
      ),
    );
  }

  Future<void> _showDatePickerDialog() async {
    final result = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (context) => CardDatePickerDialog(
        initialStartDate: widget.card.startDate,
        initialDueDate: widget.card.dueDate,
      ),
    );

    if (result != null) {
      WebsocketService.updateCard(
        cardId: widget.card.id,
        startDate: result['startDate'],
        dueDate: result['dueDate'],
        updateDates: true,
      );
    }
  }

  bool _matchesSearch() {
    if (widget.searchQuery.isEmpty) return false;
    final query = widget.searchQuery.toLowerCase();
    return widget.card.title.toLowerCase().contains(query) ||
        widget.card.content.toLowerCase().contains(query) ||
        widget.card.assignedUsers.any(
          (user) => user.username.toLowerCase().contains(query),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    );
    final canEdit = BoardPermissionsService.canEdit;
    final isHighlighted = _matchesSearch();

    final cardWidget = Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      color: isHighlighted ? Colors.yellow.shade100 : null,
      elevation: isHighlighted ? 4 : 1,
      shape: isHighlighted
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.orange.shade400, width: 2),
            )
          : null,
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
                          decoration: InputDecoration(
                            hintText: l10n.cardTitle,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
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
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      const SizedBox(height: 4),
                      if (canEdit)
                        TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          decoration: InputDecoration(
                            hintText: l10n.cardDescription,
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
                      if (widget.card.startDate != null ||
                          widget.card.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (widget.card.startDate != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_arrow,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateFormat.format(widget.card.startDate!),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            if (widget.card.dueDate != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateFormat.format(widget.card.dueDate!),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
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
                        tooltip: l10n.deleteCardTooltip,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _confirmDelete,
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        icon: const Icon(Icons.person_add, size: 18),
                        color: Colors.blue,
                        tooltip: l10n.assignUsersTooltip,
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
                      const SizedBox(height: 4),
                      IconButton(
                        icon: const Icon(Icons.calendar_month, size: 18),
                        color: Colors.green,
                        tooltip: l10n.setDeadlinesTooltip,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _showDatePickerDialog,
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
                    return AssignedUserAvatar(
                      user: user,
                      cardId: widget.card.id,
                      canEdit: canEdit,
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (canEdit && widget.isDraggable) {
      return DragTarget<TrelloCard>(
        onWillAcceptWithDetails: (details) {
          return BoardPermissionsService.canEdit;
        },
        onAcceptWithDetails: (details) {
          final draggedCard = details.data;
          // Don't update if the card is the same position
          if (draggedCard.id == widget.card.id) return;
          // Don't update if dropped under itself
          if (widget.cardAboveId != null &&
              widget.cardAboveId == draggedCard.id) {
            return;
          }
          // Move card to this card's position
          WebsocketService.updateCard(
            cardId: draggedCard.id,
            columnId: widget.card.columnId,
            newPos: widget.card.id,
          );
        },
        builder: (context, candidateData, rejectedData) {
          final draggedCard = candidateData.isNotEmpty
              ? candidateData[0]
              : null;
          final isHovering =
              draggedCard != null &&
              draggedCard.id != widget.card.id &&
              widget.cardAboveId != draggedCard.id;

          if (isHovering) {
            return _draggableCard(
              Column(
                children: [
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  cardWidget,
                ],
              ),
            );
          }
          return _draggableCard(cardWidget);
        },
      );
    }
    return cardWidget;
  }

  Widget _draggableCard(Widget card) {
    return LongPressDraggable<TrelloCard>(
      data: widget.card,
      delay: AppConfig.dragDelay,
      feedback: SizedBox(
        width: 278,
        child: Opacity(
          opacity: 0.7,
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
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: card),
      child: card,
    );
  }
}
