import 'package:flutter/material.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/screens/home_screen/widgets/board_card_widget.dart';

class BoardsSectionWidget extends StatelessWidget {
  final List<Board> boards;

  const BoardsSectionWidget({super.key, required this.boards});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          Expanded(
            child: ListView.builder(
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                return BoardCardWidget(board: board);
              },
            ),
          ),
      ],
    );
  }
}
