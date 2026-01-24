import 'package:flutter/material.dart';
import 'package:frontend/models/api/assigned_card.dart';
import 'package:intl/intl.dart';

class AssignedCardWidget extends StatelessWidget {
  final AssignedCard card;

  const AssignedCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isOverdue = card.dueDate != null && card.dueDate!.isBefore(now);
    final isDueSoon =
        card.dueDate != null &&
        card.dueDate!.isAfter(now) &&
        card.dueDate!.difference(now).inDays < 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/board/${card.boardId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${card.boardTitle} • ${card.columnTitle}',
                style: theme.textTheme.bodySmall,
              ),
              if (card.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isOverdue
                          ? Colors.red
                          : isDueSoon
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('dd/MM/yyyy').format(card.dueDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue
                            ? Colors.red
                            : isDueSoon
                            ? Colors.orange
                            : Colors.grey[600],
                        fontWeight: isOverdue || isDueSoon
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
