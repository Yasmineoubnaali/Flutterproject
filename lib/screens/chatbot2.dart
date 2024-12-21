import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotSpeechPage extends StatefulWidget {
  const ChatBotSpeechPage({Key? key}) : super(key: key);

  @override
  _ChatBotSpeechPageState createState() => _ChatBotSpeechPageState();
}

class _ChatBotSpeechPageState extends State<ChatBotSpeechPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  /// Méthode pour démarrer l'écoute vocale
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) async {
          _lastWords = result.recognizedWords;

          if (result.finalResult) { // Quand vous arrêtez de parler
            _stopListening();
            _sendMessage(_lastWords);
          }
        },
      );
    }
  }

  /// Méthode pour arrêter l'écoute
  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  /// Méthode pour envoyer le message au bot
  Future<void> _sendMessage(String userMessage) async {
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
  }

  /// Appel API pour obtenir la réponse du bot
  Future<String?> _getBotResponse(String userMessage) async {
    const String apiUrl = 'http://localhost:11434/api/chat';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "model": "llama3.2:1b", // Changez par le modèle utilisé
          "messages": [
            {"role": "user", "content": userMessage}
          ],
          "stream": false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message']['content'] ?? 'No response from the bot.';
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
      appBar: AppBar(title: const Text('Voice ChatBot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final chat = _chatHistory[index];
                return ListTile(
                  title: Text(
                    '${chat["role"]}: ${chat["message"]}',
                    style: TextStyle(
                      fontWeight: chat["role"] == "You"
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  tooltip: 'Start/Stop Listening',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
