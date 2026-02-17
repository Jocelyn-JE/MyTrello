import 'package:flutter/material.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/services/websocket/websocket_service.dart';
import 'package:frontend/utils/deterministic_color.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AssignedUserAvatar extends StatefulWidget {
  final TrelloUser user;
  final String cardId;
  final bool canEdit;

  const AssignedUserAvatar({
    super.key,
    required this.user,
    required this.cardId,
    required this.canEdit,
  });

  @override
  State<AssignedUserAvatar> createState() => _AssignedUserAvatarState();
}

class _AssignedUserAvatarState extends State<AssignedUserAvatar> {
  bool _isHovered = false;

  Future<void> _confirmUnassign() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.unassignUser,
      content: l10n.removeUserFromCard(widget.user.username),
      confirmText: l10n.unassign,
    );

    if (confirmed == true) {
      WebsocketService.unassignUserFromCard(widget.cardId, widget.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.user.username,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.canEdit) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (widget.canEdit) {
            setState(() => _isHovered = false);
          }
        },
        child: GestureDetector(
          onTap: widget.canEdit ? _confirmUnassign : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: getColorFromId(widget.user.id),
                child: Text(
                  widget.user.username.isNotEmpty
                      ? widget.user.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (_isHovered && widget.canEdit)
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: _confirmUnassign,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
