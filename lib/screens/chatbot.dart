import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _chatHistory = [];

  Future<void> _sendMessage() async {
    String userMessage = _controller.text;
    if (userMessage.isEmpty) return;

    setState(() {
      _chatHistory.add({"role": "You", "message": userMessage});
    });

    final response = await _getBotResponse(userMessage);

    if (response != null) {
      setState(() {
        _chatHistory.add({"role": "Bot", "message": response});
      });
    }

    _controller.clear();
  }

  Future<String?> _getBotResponse(String userMessage) async {
    const String apiUrl = 'http://10.0.2.2:11434/api/chat'; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "model": "llama3.2:1b",
          "messages": [
            {"role": "user", "content": userMessage}
          ],
          "stream": false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message']['content'] ?? 'No response from API.';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = _chatHistory[index];
                  bool isUserMessage = chat["role"] == "You";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Align(
                      alignment:
                          isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          chat["message"]!,
                          style: TextStyle(
                            color: isUserMessage ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blueAccent,
                  iconSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
