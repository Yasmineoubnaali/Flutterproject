import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RealTimeSpeechBotPage extends StatefulWidget {
  const RealTimeSpeechBotPage({Key? key}) : super(key: key);

  @override
  State<RealTimeSpeechBotPage> createState() => _RealTimeSpeechBotPageState();
}

class _RealTimeSpeechBotPageState extends State<RealTimeSpeechBotPage> {
  late stt.SpeechToText _speech;
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _userInput = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeTTS();
  }

  /// Initialise Text-to-Speech
  void _initializeTTS() async {
    await _flutterTts.setLanguage('en-US'); // Définissez votre langue
    await _flutterTts.setSpeechRate(0.5);
  }

  /// Démarre la reconnaissance vocale en temps réel
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "notListening") {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) async {
          setState(() {
            _userInput = result.recognizedWords; // Met à jour le texte en direct
          });

          if (result.finalResult) {
            _stopListening();
            await _handleBotResponse(_userInput); // Appelle le bot
          }
        },
        listenMode: stt.ListenMode.confirmation,
        partialResults: true, // Permet les résultats partiels en temps réel
      );
    }
  }

  /// Stoppe la reconnaissance vocale
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  /// Envoie le texte au bot et reçoit la réponse
  Future<void> _handleBotResponse(String message) async {
    if (message.isEmpty) return;

    final response = await _getBotResponse(message);

    if (response != null) {
      // Lecture vocale de la réponse du bot
      await _flutterTts.speak(response);
    }
  }

  /// Appel API pour obtenir la réponse du bot
  Future<String?> _getBotResponse(String userMessage) async {
    const String apiUrl = 'http://192.168.8.125:11434/api/chat'; // Remplacez localhost par l'IP de votre machine

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
      appBar: AppBar(title: const Text('Real-Time Speech-to-Speech Bot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _userInput, // Affiche les paroles reconnues en temps réel
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              tooltip: 'Start/Stop Listening',
            ),
          ],
        ),
      ),
    );
  }
}
