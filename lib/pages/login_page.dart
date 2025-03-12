import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../config.dart';
import '../models/user_model.dart';
import '../notification_service.dart';
import 'home_page.dart';

class TempUser {
  final String email;
  final String password;

  TempUser({required this.email, required this.password});

  Map<String, String> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String apiUrl = '${Config.baseUrl}maintenance/login';

  // Text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorMessage('Please enter both email and password.');
      return;
    }

    TempUser user = TempUser(email: email, password: password);
    final url = Uri.parse(apiUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Update UserModel
        Provider.of<UserModel>(context, listen: false).setUser(responseData);

        // Show a notification
        NotificationService.showNotification(
          title: 'Login Successful',
          body: 'Welcome back, ${responseData['user']['firstname']}!',
        );

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (response.statusCode == 499) {
        _showErrorMessage('User not found. Please register.');
      } else if (response.statusCode == 498) {
        _showErrorMessage('Incorrect password. Please try again.');
      } else {
        _showErrorMessage('Login failed. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('An error occurred. Please try again later.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ktm_logo.png',
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 15),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 25),
              MyButton(
                text: "Sign In",
                onTap: login,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
