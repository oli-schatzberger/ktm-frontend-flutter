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

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final String apiUrl = '${Config.baseUrl}maintenance/register';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String emailError = '';
  String firstNameError = '';
  String lastNameError = '';
  String passwordError = '';
  String confirmPasswordError = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmail);
    firstNameController.addListener(_validateFirstName);
    lastNameController.addListener(_validateLastName);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // VALIDATIONS

  void _validateEmail() {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      if (email.isEmpty) {
        emailError = 'Email darf nicht leer sein.';
      } else if (!emailRegex.hasMatch(email)) {
        emailError = 'Ungültige E-Mail-Adresse.';
      } else {
        emailError = '';
      }
    });
  }

  void _validateFirstName() {
    final firstname = firstNameController.text.trim();
    final nameRegex = RegExp(r"^[a-zA-ZäöüÄÖÜß\s'-]+$");
    setState(() {
      if (firstname.isEmpty) {
        firstNameError = 'Vorname darf nicht leer sein.';
      } else if (!nameRegex.hasMatch(firstname)) {
        firstNameError = 'Vorname enthält ungültige Zeichen.';
      } else {
        firstNameError = '';
      }
    });
  }

  void _validateLastName() {
    final lastname = lastNameController.text.trim();
    final nameRegex = RegExp(r"^[a-zA-ZäöüÄÖÜß\s'-]+$");
    setState(() {
      if (lastname.isEmpty) {
        lastNameError = 'Nachname darf nicht leer sein.';
      } else if (!nameRegex.hasMatch(lastname)) {
        lastNameError = 'Nachname enthält ungültige Zeichen.';
      } else {
        lastNameError = '';
      }
    });
  }

  void _validatePassword() {
    final password = passwordController.text.trim();
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    setState(() {
      if (password.isEmpty) {
        passwordError = 'Passwort darf nicht leer sein.';
      } else if (!passwordRegex.hasMatch(password)) {
        passwordError = 'Mind. 8 Zeichen, 1 Großbuchstabe, 1 Zahl.';
      } else {
        passwordError = '';
      }
    });
  }

  void _validateConfirmPassword() {
    final confirmPassword = confirmPasswordController.text.trim();
    setState(() {
      if (confirmPassword.isEmpty) {
        confirmPasswordError = 'Bestätigung darf nicht leer sein.';
      } else if (confirmPassword != passwordController.text.trim()) {
        confirmPasswordError = 'Passwörter stimmen nicht überein.';
      } else {
        confirmPasswordError = '';
      }
    });
  }

  bool _validateAllFields() {
    _validateFirstName();
    _validateLastName();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();
    return firstNameError.isEmpty &&
        lastNameError.isEmpty &&
        emailError.isEmpty &&
        passwordError.isEmpty &&
        confirmPasswordError.isEmpty;
  }

  Future<void> _register() async {
    if (!_validateAllFields()) {
      _showErrorMessage('Bitte korrigiere die Fehler im Formular.');
      return;
    }

    setState(() => isLoading = true);

    final user = {
      'firstname': firstNameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'passwordConfirm': confirmPasswordController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Provider.of<UserModel>(context, listen: false).setUser(responseData);

        NotificationService.showNotification(
          title: 'Erfolgreich registriert',
          body: 'Willkommen ${responseData['user']['firstname']}!',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showErrorMessage('Registrierung fehlgeschlagen: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorMessage('Fehler. Bitte erneut versuchen.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 👇 Smaller logo
              Image.asset(
                'assets/images/ktm_logo.png',
                height: 80, // 👈 reduced from 120 to 80
                width: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),

              // FIRST NAME
              MyTextField(
                controller: firstNameController,
                hintText: 'First Name',
                obscureText: false,
              ),
              _buildErrorText(firstNameError),

              // LAST NAME
              MyTextField(
                controller: lastNameController,
                hintText: 'Last Name',
                obscureText: false,
              ),
              _buildErrorText(lastNameError),

              // EMAIL
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              _buildErrorText(emailError),

              // PASSWORD
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              _buildErrorText(passwordError),

              // CONFIRM PASSWORD
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              _buildErrorText(confirmPasswordError),

              const SizedBox(height: 30),

              MyButton(
                text: isLoading ? 'Loading...' : 'Sign Up',
                onTap: isLoading ? null : _register,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login",
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

  Widget _buildErrorText(String error) {
    if (error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          error,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }
}
