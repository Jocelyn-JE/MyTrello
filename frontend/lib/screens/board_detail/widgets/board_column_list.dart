import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/board_detail/widgets/add_card_dialog.dart';
import 'package:frontend/screens/board_detail/widgets/trello_column_widget.dart';
import 'package:frontend/services/board_permissions_service.dart';
import 'package:frontend/websocket/models/server_types.dart';
import 'package:frontend/websocket/websocket_service.dart';

class BoardColumnList extends StatefulWidget {
  final List<TrelloColumn> _columns;
  final String _searchQuery;
  final String _boardId;
  const BoardColumnList({
    super.key,
    required List<TrelloColumn> columns,
    required String searchQuery,
    required String boardId,
  }) : _columns = columns,
       _searchQuery = searchQuery,
       _boardId = boardId;

  @override
  State<BoardColumnList> createState() => _BoardColumnListState();
}

class _BoardColumnListState extends State<BoardColumnList> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 6.0,
      radius: const Radius.circular(4),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              // Convert vertical scroll to horizontal scroll
              final offset = pointerSignal.scrollDelta.dy;
              _scrollController.jumpTo(
                (_scrollController.offset + offset).clamp(
                  0.0,
                  _scrollController.position.maxScrollExtent,
                ),
              );
            }
          },
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount:
                widget._columns.length +
                (BoardPermissionsService.canEdit ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget._columns.length &&
                  BoardPermissionsService.canEdit) {
                // Add column button with drag target
                return DragTarget<TrelloColumn>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    final draggedColumn = details.data;
                    // Move to end by passing null as newPos
                    WebsocketService.moveColumn(draggedColumn.id, null);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering =
                        candidateData.isNotEmpty &&
                        candidateData[0]!.index != widget._columns.length - 1;
                    final button = ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen.shade200,
                      ),
                      onPressed: () {
                        WebsocketService.createColumn('New Column');
                      },
                      child: const Icon(Icons.add),
                    );

                    if (isHovering) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 4,
                            margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          button,
                        ],
                      );
                    }
                    return button;
                  },
                );
              }
              final column = widget._columns[index];
              return TrelloColumnWidget(
                column: column,
                onAddCard: () => showDialog(
                  builder: (context) => AddCardDialog(columnId: column.id),
                  context: context,
                ),
                columnBeforeId: index > 0
                    ? widget._columns[index - 1].id
                    : null,
                searchQuery: widget._searchQuery,
                boardId: widget._boardId,
              );
            },
          ),
        ),
      ),
    );
  }
}
