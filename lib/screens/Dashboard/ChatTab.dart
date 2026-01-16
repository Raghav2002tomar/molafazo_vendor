import 'package:flutter/material.dart';

import '../chat/screens/chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        // leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          ChatTile(
            name: 'Sarah',
            message: "I'm interested in buying.",
            image: 'https://i.pravatar.cc/150?img=47',
          ),
          ChatTile(
            name: 'Alex',
            message: 'Is this still available?',
            image: 'https://i.pravatar.cc/150?img=12',
          ),
          ChatTile(
            name: 'Mike',
            message: 'Can you ship it today?',
            image: 'https://i.pravatar.cc/150?img=59',
          ),
          ChatTile(
            name: 'Emily',
            message: 'I have a question about the size.',
            image: 'https://i.pravatar.cc/150?img=32',
          ),
          ChatTile(
            name: 'David',
            message: "I'd like to negotiate the price.",
            image: 'https://i.pravatar.cc/150?img=18',
          ),
        ],
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String image;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              name: name,
              image: image,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User: $name',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last message: "$message"',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
