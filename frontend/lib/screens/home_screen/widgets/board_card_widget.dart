import 'package:flutter/material.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/utils/deterministic_color.dart';
import 'package:frontend/l10n/app_localizations.dart';

class BoardCardWidget extends StatelessWidget {
  final Board board;

  const BoardCardWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getColorFromId(board.id),
          child: Text(
            board.title.isNotEmpty ? board.title[0].toUpperCase() : 'B',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          board.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.owner}: ${board.owner.username}'),
            if (board.members.isNotEmpty || board.viewers.isNotEmpty)
              Text(
                l10n.membersViewersCount(
                  board.members.length,
                  board.viewers.length,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, '/board/${board.id}');
        },
      ),
    );
  }
}
