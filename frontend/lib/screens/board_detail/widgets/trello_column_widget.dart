import 'package:flutter/material.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/screens/board_detail/widgets/add_card_dialog.dart';
import 'package:frontend/services/board_permissions_service.dart';
import 'package:frontend/widgets/confirmation_dialog.dart';
import 'package:frontend/screens/board_detail/widgets/trello_card_widget.dart';
import 'package:frontend/services/websocket/websocket_service.dart';
import 'package:frontend/utils/app_config.dart';
import 'package:frontend/l10n/app_localizations.dart';

class TrelloColumnWidget extends StatefulWidget {
  final TrelloColumn column;
  final String? columnBeforeId;
  final String searchQuery;
  final String boardId;

  const TrelloColumnWidget({
    super.key,
    required this.column,
    this.columnBeforeId,
    this.searchQuery = '',
    required this.boardId,
  });

  @override
  State<TrelloColumnWidget> createState() => _TrelloColumnWidgetState();
}

class _TrelloColumnWidgetState extends State<TrelloColumnWidget> {
  TextEditingController? _titleController;

  @override
  void initState() {
    super.initState();
    // Only create controller if user can edit
    if (BoardPermissionsService.canEdit) {
      _titleController = TextEditingController(text: widget.column.title);
    }
  }

  @override
  void didUpdateWidget(TrelloColumnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (BoardPermissionsService.canEdit &&
        oldWidget.column.title != widget.column.title) {
      _titleController?.text = widget.column.title;
    }
  }

  @override
  void dispose() {
    _titleController?.dispose();
    super.dispose();
  }

  void _saveTitle() {
    if (_titleController == null) return;
    final newTitle = _titleController!.text;
    if (newTitle.isNotEmpty && newTitle != widget.column.title) {
      WebsocketService.renameColumn(widget.column.id, newTitle);
    }
  }

  Future<void> _confirmDeleteColumn() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.deleteColumn,
      content: l10n.deleteColumnConfirmation(widget.column.title),
    );

    if (confirmed == true) {
      WebsocketService.deleteColumn(widget.column.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canEdit = BoardPermissionsService.canEdit;

    final columnWidget = SizedBox(
      width: 300,
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canEdit)
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: l10n.columnTitle,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  onEditingComplete: () => _saveTitle(),
                  onSubmitted: (_) {
                    _saveTitle();
                    FocusScope.of(context).unfocus();
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    widget.column.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Divider(),
              // Cards list with drag target
              Expanded(
                child: DragTarget<TrelloCard>(
                  onWillAcceptWithDetails: (details) {
                    return BoardPermissionsService.canEdit;
                  },
                  onAcceptWithDetails: (details) {
                    final draggedCard = details.data;
                    // Move card to this column let server assign the index
                    WebsocketService.updateCard(
                      cardId: draggedCard.id,
                      columnId: widget.column.id,
                    );
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return Container(
                      decoration: isHovering
                          ? BoxDecoration(
                              color: Colors.lightGreen.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.lightGreen,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                      child: widget.column.cards.isEmpty
                          ? Center(
                              child: Text(
                                isHovering ? l10n.dropHere : l10n.noCards,
                                style: TextStyle(
                                  color: isHovering
                                      ? Colors.lightGreen
                                      : Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: widget.column.cards.length,
                              itemBuilder: (context, index) {
                                final card = widget.column.cards[index];
                                return TrelloCardWidget(
                                  card: card,
                                  isDraggable: true,
                                  cardAboveId: index > 0
                                      ? widget.column.cards[index - 1].id
                                      : null,
                                  searchQuery: widget.searchQuery,
                                  boardId: widget.boardId,
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Add card button (only for editors)
              if (canEdit) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.addCard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade100,
                  ),
                  onPressed: () {
                    showDialog(
                      builder: (context) =>
                          AddCardDialog(columnId: widget.column.id),
                      context: context,
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Delete column button
                IconButton(
                  color: Colors.red,
                  icon: const Icon(Icons.delete),
                  tooltip: l10n.deleteColumn,
                  onPressed: _confirmDeleteColumn,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!canEdit) {
      return columnWidget;
    }

    // Wrap in DragTarget to allow dropping columns before this one
    return DragTarget<TrelloColumn>(
      onWillAcceptWithDetails: (details) {
        return BoardPermissionsService.canEdit;
      },
      onAcceptWithDetails: (details) {
        final draggedColumn = details.data;
        // Don't update if the column is the same position
        if (draggedColumn.id == widget.column.id) return;
        // Don't update if dropped under itself
        if (widget.columnBeforeId != null &&
            widget.columnBeforeId == draggedColumn.id) {
          return;
        }
        // Move card to this card's position
        WebsocketService.moveColumn(draggedColumn.id, widget.column.id);
      },
      builder: (context, candidateData, rejectedData) {
        final draggedColumn = candidateData.isNotEmpty
            ? candidateData[0]
            : null;
        final isHovering =
            draggedColumn != null &&
            draggedColumn.id != widget.column.id &&
            widget.columnBeforeId != draggedColumn.id;

        if (isHovering) {
          return _draggableColumn(
            Row(
              children: [
                Container(
                  width: 4,
                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                columnWidget,
              ],
            ),
          );
        }
        return _draggableColumn(columnWidget);
      },
    );
  }

  Widget _draggableColumn(Widget column) {
    final l10n = AppLocalizations.of(context)!;
    return LongPressDraggable<TrelloColumn>(
      data: widget.column,
      delay: AppConfig.dragDelay,
      feedback: SizedBox(
        width: 300,
        child: Opacity(
          opacity: 0.7,
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.column.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(),
                  Text(
                    l10n.cardsCount(widget.column.cards.length),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: column),
      child: column,
    );
  }
}
