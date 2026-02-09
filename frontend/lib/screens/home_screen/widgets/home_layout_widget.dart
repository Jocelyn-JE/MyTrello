import 'package:flutter/material.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/models/api/assigned_card.dart';
import 'package:frontend/screens/home_screen/widgets/boards_section_widget.dart';
import 'package:frontend/screens/home_screen/widgets/assigned_cards_section_widget.dart';
import 'package:frontend/screens/home_screen/widgets/assigned_card_widget.dart';
import 'package:frontend/screens/home_screen/widgets/board_card_widget.dart';

class HomeLayoutWidget extends StatelessWidget {
  final List<Board> boards;
  final List<AssignedCard> assignedCards;

  const HomeLayoutWidget({
    super.key,
    required this.boards,
    required this.assignedCards,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;

        if (isWideScreen) {
          return _buildWideLayout(context);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Boards
          Expanded(flex: 2, child: BoardsSectionWidget(boards: boards)),
          // Vertical divider separator
          if (assignedCards.isNotEmpty) ...[
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey[300],
            ),
            // Right column - Assigned Cards
            SizedBox(
              width: 300,
              child: AssignedCardsSectionWidget(assignedCards: assignedCards),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: ListView(
        children: [
          if (assignedCards.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Assigned to You',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: assignedCards.length,
                itemBuilder: (context, index) {
                  final card = assignedCards[index];
                  return AssignedCardWidget(card: card);
                },
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 12, color: Colors.grey[300]),
            const SizedBox(height: 8),
          ],
          Text(
            'Your Boards',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (boards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No boards yet. Create your first board!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                return BoardCardWidget(board: board);
              },
            ),
        ],
      ),
    );
  }
}
