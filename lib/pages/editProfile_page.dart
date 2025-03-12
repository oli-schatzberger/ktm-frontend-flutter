import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserModel>(context, listen: false);
    _firstnameController.text = user.firstname ?? '';
    _lastnameController.text = user.lastname ?? '';
    _emailController.text = user.email ?? '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = Provider.of<UserModel>(context, listen: false);

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final payload = {
      "email": user.email,
      "password": _passwordController.text,
      "user": {
        "firstname": _firstnameController.text,
        "lastname": _lastnameController.text,
        "email": _emailController.text,
        "password": _passwordController.text, // Sending updated password
      }
    };

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}maintenance/editProfile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final updatedUser = json.decode(response.body);

        // Update the user in the provider
        user.setUser({
          "user": {
            "email": updatedUser["email"],
            "firstname": updatedUser["firstname"],
            "lastname": updatedUser["lastname"],
          },
          "bikes": user.bikes ?? [], // Keep existing bikes
        });

        // Navigate back or show a success message
        Navigator.pop(context);
      } else if (response.statusCode == 498) {
        setState(() {
          errorMessage = 'Wrong password. Please try again.';
        });
      } else {
        setState(() {
          errorMessage =
          'Failed to update profile: ${response.statusCode} ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),

                // Firstname
                TextFormField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter first name' : null,
                ),
                const SizedBox(height: 16),

                // Lastname
                TextFormField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter last name' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16),

                // Save Button
                ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
