import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l10n.selectStartDate,
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
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l10n.selectDueDate,
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
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    );

    return AlertDialog(
      title: Text(l10n.setDeadlines),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.startDate,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                          : l10n.selectDate,
                    ),
                  ),
                ),
                if (_startDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearStartDate,
                    tooltip: l10n.clearStartDate,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dueDate,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                          : l10n.selectDate,
                    ),
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearDueDate,
                    tooltip: l10n.clearDueDate,
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
                        l10n.durationDays(
                          _dueDate!.difference(_startDate!).inDays,
                        ),
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
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'startDate': _startDate,
              'dueDate': _dueDate,
            });
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
