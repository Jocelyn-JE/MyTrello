import 'package:flutter/material.dart';
import 'package:frontend/models/api/assigned_card.dart';
import 'package:frontend/screens/home_screen/widgets/assigned_card_widget.dart';

class AssignedCardsSectionWidget extends StatelessWidget {
  final List<AssignedCard> assignedCards;

  const AssignedCardsSectionWidget({super.key, required this.assignedCards});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned to You',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: assignedCards.length,
            itemBuilder: (context, index) {
              final card = assignedCards[index];
              return AssignedCardWidget(card: card);
            },
          ),
        ),
      ],
    );
  }
}
