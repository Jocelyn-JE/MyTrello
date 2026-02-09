import 'package:flutter/material.dart';
import 'package:frontend/utils/deterministic_color.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/services/websocket/websocket_service.dart';
import 'package:intl/intl.dart';

class BoardChatDrawer extends StatefulWidget {
  final List<TrelloChatMessage> _chatMessages;
  const BoardChatDrawer({
    super.key,
    required List<TrelloChatMessage> chatMessages,
  }) : _chatMessages = chatMessages;

  @override
  State<BoardChatDrawer> createState() => _BoardChatDrawerState();
}

class _BoardChatDrawerState extends State<BoardChatDrawer> {
  final TextEditingController _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerticalScreen = screenHeight > screenWidth;

    // Use more space on vertical screens (up to 90%) and less on wide screens (40%)
    final drawerWidth = isVerticalScreen
        ? screenWidth * 0.8
        : screenWidth * 0.4;

    return Drawer(
      width: drawerWidth,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightGreen.shade200),
            child: const Center(
              child: Text(
                'Board Chat',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Chat messages list
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              reverse: true,
              itemCount: widget._chatMessages.length,
              itemBuilder: (context, index) {
                final message = widget._chatMessages[index];
                final now = DateTime.now();
                final isToday =
                    message.createdAt.year == now.year &&
                    message.createdAt.month == now.month &&
                    message.createdAt.day == now.day;

                final timeString = DateFormat(
                  'HH:mm',
                ).format(message.createdAt);
                final dateString = DateFormat(
                  'dd/MM/yyyy',
                ).format(message.createdAt);

                return ListTile(
                  leading: Tooltip(
                    message: '${message.user.username} (${message.user.email})',
                    child: CircleAvatar(
                      backgroundColor: getColorFromId(message.user.id),
                      child: Text(
                        message.user.username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  title: Text(
                    message.user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(message.content),
                  trailing: Text(
                    isToday ? timeString : '$dateString\n$timeString',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          // Chat input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                labelText: 'Type a message',
                border: const OutlineInputBorder(),
                // Send button
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendChatMessage,
                  tooltip: 'Send',
                ),
              ),
              onSubmitted: (_) => _sendChatMessage(),
            ),
          ),
        ],
      ),
    );
  }

  void _sendChatMessage() {
    final content = _chatController.text.trim();
    if (content.isNotEmpty) {
      WebsocketService.sendChatMessage(content);
      _chatController.clear();
    }
  }
}
