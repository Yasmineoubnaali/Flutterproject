import 'package:flutter/material.dart';
import 'package:oubnaali_app/screens/login_page.dart';
// Importez la page RegisterPage
// import 'path_to_register_page.dart';  // Remplacez avec le chemin réel vers RegisterPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _logout() {
    // Déconnexion
    print('Logged out');
    // Remplacez la page actuelle par RegisterPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>const LoginPage()), // Remplacez RegisterPage() avec votre page de registre réelle
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 150, 150, 151),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/yass1.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Yasmine Oubnaali',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('ChatBot '),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('ChatBot speech to text '),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat2');
              },
            ),
             ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('ChatBot speech to speech '),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat3');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Fruit Classifier'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/fruits');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Classification Fruits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action d'exploration
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Explore', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
