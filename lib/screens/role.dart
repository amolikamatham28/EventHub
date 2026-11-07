import 'package:flutter/material.dart';
import 'auth.dart';

const Color roleNavy = Color(0xFF202B45);
const Color roleCoral = Color(0xFFF07861);
const Color roleIvory = Color(0xFFFAF8F4);
const Color roleTextGrey = Color(0xFF555555);

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  void openAuth(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: roleIvory,
      appBar: AppBar(
        backgroundColor: roleIvory,
        elevation: 0,
        foregroundColor: roleNavy,
        title: const Text(
          'EventHub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              children: [
                const Text(
                  'Welcome to EventHub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: roleNavy,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose how you want to use the platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: roleTextGrey,
                  ),
                ),
                const SizedBox(height: 35),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 550) {
                      return Column(
                        children: [
                          _roleCard(
                            context,
                            'Attendee',
                            'Explore events, register and manage your tickets.',
                            Icons.event_available,
                            roleCoral,
                          ),
                          const SizedBox(height: 20),
                          _roleCard(
                            context,
                            'Organizer',
                            'Create events, manage registrations and track seats.',
                            Icons.event_note,
                            roleNavy,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _roleCard(
                            context,
                            'Attendee',
                            'Explore events, register and manage your tickets.',
                            Icons.event_available,
                            roleCoral,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _roleCard(
                            context,
                            'Organizer',
                            'Create events, manage registrations and track seats.',
                            Icons.event_note,
                            roleNavy,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: roleNavy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: roleTextGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => openAuth(context, title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: Text('Continue as $title'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}