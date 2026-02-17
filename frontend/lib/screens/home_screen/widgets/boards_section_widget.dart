import 'package:flutter/material.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/screens/home_screen/widgets/board_card_widget.dart';
import 'package:frontend/l10n/app_localizations.dart';

class BoardsSectionWidget extends StatelessWidget {
  final List<Board> boards;

  const BoardsSectionWidget({super.key, required this.boards});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.yourBoards,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (boards.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.createFirstBoard,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
