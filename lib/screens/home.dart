import 'package:flutter/material.dart';
import 'role.dart';

const Color navy = Color(0xFF202B45);
const Color coral = Color(0xFFF07861);
const Color ivory = Color(0xFFFAF8F4);
const Color lavender = Color(0xFFE9EAF2);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openRoles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 750;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildNavbar(context, isMobile),

                // Hero section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 55,
                    vertical: 25,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 25 : 45),
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildHeroText(context),
                                  const SizedBox(height: 28),
                                  _buildHeroImage(
                                    width: double.infinity,
                                    height: 220,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildHeroText(context),
                                  ),
                                  const SizedBox(width: 35),
                                  _buildHeroImage(
                                    width: 370,
                                    height: 290,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                _buildFeatures(isMobile),
                _buildHowItWorks(isMobile),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Navigation bar
  Widget _buildNavbar(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 55,
        vertical: 22,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              const Icon(
                Icons.event_available,
                color: coral,
                size: 32,
              ),
              const SizedBox(width: 10),
              const Text(
                'EventHub',
                style: TextStyle(
                  color: navy,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              if (!isMobile)
                TextButton(
                  onPressed: () => openRoles(context),
                  child: const Text(
                    'Explore',
                    style: TextStyle(
                      color: navy,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: () => openRoles(context),
                  icon: const Icon(
                    Icons.explore,
                    color: navy,
                  ),
                  tooltip: 'Explore events',
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero text
  Widget _buildHeroText(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 750;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR CAMPUS, YOUR EVENTS',
          style: TextStyle(
            color: coral,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 22),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Find Events Worth Looking Forward To.',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Explore college festivals, technical events, workshops and activities. Find your next campus experience, all in one place.',
          style: TextStyle(
            color: Color(0xFFE5E8EF),
            fontSize: 17,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () => openRoles(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: coral,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 27,
              vertical: 19,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Explore Events',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  // Hero image with Stack overlay
  Widget _buildHeroImage({
    required double width,
    required double height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=900',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: lavender,
                  child: const Center(
                    child: Icon(
                      Icons.calendar_month,
                      size: 65,
                      color: navy,
                    ),
                  ),
                );
              },
            ),

            // Label displayed over the image
            Positioned(
              left: 15,
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'CAMPUS EVENTS',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Features section
  Widget _buildFeatures(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 22 : 65,
        vertical: 55,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'Everything You Need for Campus Events',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'One platform for students and event organizers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF596174),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 35),

              Wrap(
                spacing: 22,
                runSpacing: 22,
                alignment: WrapAlignment.center,
                children: const [
                  FeatureCard(
                    icon: Icons.search,
                    title: 'Discover Events',
                    description:
                        'Explore college festivals, competitions, workshops and more.',
                  ),
                  FeatureCard(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Easy Registration',
                    description:
                        'Register for campus events and receive your digital ticket.',
                  ),
                  FeatureCard(
                    icon: Icons.event_note,
                    title: 'Manage Events',
                    description:
                        'Organize college events, manage registrations and track seats.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // How it works section
  Widget _buildHowItWorks(bool isMobile) {
    final steps = [
      [
        '01',
        'Explore',
        'Browse campus events and find something you like.',
      ],
      [
        '02',
        'Register',
        'Complete your event registration in a few steps.',
      ],
      [
        '03',
        'Participate',
        'Get your digital ticket and enjoy the event.',
      ],
    ];

    return Container(
      width: double.infinity,
      color: lavender,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 22 : 65,
        vertical: 55,
      ),
      child: Column(
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              color: navy,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 35),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Wrap(
                spacing: 35,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: steps.map((step) {
                  return SizedBox(
                    width: isMobile ? 280 : 290,
                    child: Column(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: coral,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            step[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step[1],
                          style: const TextStyle(
                            color: navy,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          step[2],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF50596B),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Footer
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: navy,
      padding: const EdgeInsets.all(25),
      child: const Text(
        '© 2026 EventHub',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}

// Reusable feature card
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 275,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E1DE),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9E3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: coral,
              size: 29,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF596174),
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}