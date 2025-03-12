import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../themes/theme_provider.dart';
import 'editProfile_page.dart';
import 'login_page.dart';
import 'register_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // User Info (Without Profile Picture)
            Text(
              user.firstname ?? 'No name available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              user.email ?? 'No email available',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 30),

            // Dark Mode Switch
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  CupertinoSwitch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toogleTheme();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notifications Switch
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notifications",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  CupertinoSwitch(
                    value: true, // Replace with actual notification state
                    onChanged: (value) {
                      // Handle notification toggle
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            GestureDetector(
              onTap: () {
                Provider.of<UserModel>(context, listen: false).clearUser();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(onTap: null),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
