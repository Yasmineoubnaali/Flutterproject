import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  //libérer les ressources
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Vérification des informations de l'administrateur
      if (_emailController.text == "admin@gmail.com" &&
          _passwordController.text == "admin123") {
        Navigator.pushNamed(context, "/home");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion en cours...')),
        );
      } else {
        // Authentification Firebase pour les autres utilisateurs
        try {
          final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          Navigator.pushNamed(context, "/home");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bienvenue ${userCredential.user?.email}!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${e.toString()}')),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black), // Icône noire
        labelText: label,
        labelStyle: TextStyle(color: Colors.black), // Texte du label en noir
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),  // Bords arrondis
          borderSide: BorderSide(color: Colors.black), // Bordure noire
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black, width: 2), // Bordure noire au focus
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      obscureText: isPassword && _obscureText,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color.fromARGB(255, 227, 228, 229),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            label: const Text("Register"),
            icon: const Icon(Icons.app_registration),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 231, 232, 233),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white, // Fond blanc
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image agrandie
                Image.asset(
                  "assets/images/logo.png",
                  width: 300, // Taille agrandie
                  height: 300,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text("Image non disponible"),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Email',
                        icon: Icons.email,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Mot de passe',
                        icon: Icons.lock,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          } else if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Text('Connexion'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
