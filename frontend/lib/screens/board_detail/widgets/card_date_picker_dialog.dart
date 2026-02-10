import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardDatePickerDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialDueDate;

  const CardDatePickerDialog({
    super.key,
    this.initialStartDate,
    this.initialDueDate,
  });

  @override
  State<CardDatePickerDialog> createState() => _CardDatePickerDialogState();
}

class _CardDatePickerDialogState extends State<CardDatePickerDialog> {
  DateTime? _startDate;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _dueDate = widget.initialDueDate;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Start Date',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If due date is before start date, adjust it
        if (_dueDate != null && _dueDate!.isBefore(picked)) {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Due Date',
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _clearStartDate() {
    setState(() {
      _startDate = null;
    });
  }

  void _clearDueDate() {
    setState(() {
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: const Text('Set Deadlines'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickStartDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _startDate != null
                          ? dateFormat.format(_startDate!)
                          : 'Select Date',
                    ),
                  ),
                ),
                if (_startDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearStartDate,
                    tooltip: 'Clear start date',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Due Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _dueDate != null
                          ? dateFormat.format(_dueDate!)
                          : 'Select Date',
                    ),
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearDueDate,
                    tooltip: 'Clear due date',
                  ),
                ],
              ],
            ),
            if (_startDate != null && _dueDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Duration: ${_dueDate!.difference(_startDate!).inDays} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'startDate': _startDate,
              'dueDate': _dueDate,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
