import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [
    {"role": "user", "text": "Hi there!"},
    {"role": "assistant", "text": "Hello! How can I help you?"},
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _messages.add({"role": "assistant", "text": "Assistant reply example."});
      _controller.clear();
    });
  }

  Widget _buildBubble(Map<String, String> msg) {
    final isUser = msg["role"] == "user";
    return BubbleSpecialOne(
      text: msg["text"] ?? "",
      isSender: isUser,
      color: isUser ? Colors.blue : Colors.grey[300]!,
      textStyle: TextStyle(
        color: isUser ? Colors.white : Colors.black87,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, idx) => _buildBubble(_messages[idx]),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message…",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
