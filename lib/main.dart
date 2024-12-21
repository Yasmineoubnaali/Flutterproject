import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/fruits_page.dart';
import 'screens/chatbot.dart' as chatbot; // Alias the chatbot import
import 'screens/chatbot2.dart' as chatbot2; // Alias the chatbot2 import
import 'screens/chatbot3.dart' as chatbot3; // Alias the chatbot3 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter oubnaali',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/fruits': (context) => FruitsPage(),
        '/chat': (context) => const chatbot.ChatBotPage(),
        '/chat2': (context) => const chatbot2.ChatBotSpeechPage(),
        '/chat3': (context) => const chatbot3.RealTimeSpeechBotPage(), // Use the chatbot2 alias
        //'/chat3': (context) => const chatbot3.RealTimeSpeechBotPage(), // Use the chatbot3 alias
      },
    );
  }
}
