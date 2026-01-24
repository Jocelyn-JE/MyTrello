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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      elevation: 1,
      child: Tooltip(
        message: 'Go to board',
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/board/${card.boardId}');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 4),
                Text(
                  card.content,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${card.boardTitle} • ${card.columnTitle}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (card.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
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
                        style: TextStyle(
                          fontSize: 11,
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
