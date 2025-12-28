import 'package:flutter/material.dart';
import 'package:frontend/board_permissions_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final canEdit = BoardPermissionsService.canEdit;

    return SizedBox(
      width: 300,
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canEdit)
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
                    // Accept any card from any column
                    return BoardPermissionsService.canEdit;
                  },
                  onAcceptWithDetails: (details) {
                    final draggedCard = details.data;
                    // Don't do anything if dropped in the same column
                    if (draggedCard.columnId == widget.column.id) {
                      return;
                    }
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
                                isHovering ? 'Drop here' : 'No cards',
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
            ],
          ),
        ),
      ),
    );
  }
}
