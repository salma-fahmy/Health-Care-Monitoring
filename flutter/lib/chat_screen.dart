import 'package:flutter/material.dart';
import 'chat_service.dart'; // Ensure this file is updated with the correct ChatService

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService(); // Updated to use ChatService
  final TextEditingController _controller = TextEditingController();
  List<String> _messages = [];

  void _sendMessage() async {
    final message = _controller.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add('You: $message');
    });
    _controller.clear();

    try {
      final response =
          await _chatService.sendMessage(message); // Updated to use ChatService
      setState(() {
        _messages.add('Bot: $response');
      });
    } catch (e) {
      setState(() {
        _messages.add('Bot: Error occurred. Please try again.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}