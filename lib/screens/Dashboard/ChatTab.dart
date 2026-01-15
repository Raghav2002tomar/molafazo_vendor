import 'package:flutter/material.dart';



class ChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Chat Tab', style: Theme.of(context).textTheme.headlineMedium),
          const Text('Messages & Support', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
