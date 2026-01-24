import 'package:flutter/material.dart';
import 'package:frontend/models/api/assigned_card.dart';
import 'package:intl/intl.dart';

class AssignedCardWidget extends StatelessWidget {
  final AssignedCard card;

  const AssignedCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = card.dueDate != null && card.dueDate!.isBefore(now);
    final isDueSoon =
        card.dueDate != null &&
        card.dueDate!.isAfter(now) &&
        card.dueDate!.difference(now).inDays < 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          card.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.content, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              '${card.boardTitle} • ${card.columnTitle}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.blue),
            ),
            if (card.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isOverdue
                          ? Colors.red
                          : isDueSoon
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(card.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? Colors.red
                            : isDueSoon
                            ? Colors.orange
                            : Colors.grey,
                        fontWeight: isOverdue || isDueSoon
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, '/board/${card.boardId}');
        },
      ),
    );
  }
}
