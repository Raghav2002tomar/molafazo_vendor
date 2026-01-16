import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  final String name;
  final String image;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          name,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SellerBubble(
                  message:
                  'Hi there! Thanks for reaching out. How can I help you today?',
                  image: 'https://i.pravatar.cc/150?img=47',
                ),
                UserBubble(
                  message:
                  "Hi! I'm interested in the vintage leather jacket you have listed. Could you tell me more about its condition?",
                  image: 'https://i.pravatar.cc/150?img=12',
                ),
                SellerBubble(
                  message:
                  'Of course! The jacket is in excellent condition for its age. There are a few minor scuffs, which add to its vintage charm. No major damage or repairs.',
                  image: 'https://i.pravatar.cc/150?img=47',
                ),
                UserBubble(
                  message:
                  "That sounds great. What are the measurements? I'm particularly interested in the chest and sleeve length.",
                  image: 'https://i.pravatar.cc/150?img=12',
                ),
              ],
            ),
          ),
          _MessageInput(),
        ],
      ),
    );
  }
}

/// ---------------- BUBBLES ----------------

class SellerBubble extends StatelessWidget {
  final String message;
  final String image;

  const SellerBubble({
    super.key,
    required this.message,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seller',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(image, width: 36, height: 36),
            ),
            const SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class UserBubble extends StatelessWidget {
  final String message;
  final String image;

  const UserBubble({
    super.key,
    required this.message,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('User',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(image, width: 36, height: 36),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// ---------------- INPUT ----------------

class _MessageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Message',
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.send, size: 26),
        ],
      ),
    );
  }
}
