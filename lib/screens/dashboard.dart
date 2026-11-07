import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App colours
const Color navy = Color(0xFF202B45);
const Color coral = Color(0xFFF07861);
const Color ivory = Color(0xFFFAF8F4);
const Color lavenderGrey = Color(0xFFE9EAF2);
const Color textGrey = Color(0xFF555555);
const Color lightText = Color(0xFFE6E6E6);

// Sample events
final List<Map<String, dynamic>> sampleEvents = [
  {
    'id': 'sample1',
    'name': 'Ignite 2026 – Annual Fest',
    'category': 'Fest',
    'date': '15 Dec 2026',
    'timings': '9:00 AM to 6:00 PM',
    'venue': 'College Auditorium',
    'description':
        'Celebrate creativity, culture and talent at our annual college fest.',
    'capacity': 100,
    'image':
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=900',
  },
  {
    'id': 'sample2',
    'name': 'CodeSprint Hackathon',
    'category': 'Technical',
    'date': '18 Dec 2026',
    'timings': '9:00 AM to 5:00 PM',
    'venue': 'CS Block',
    'description':
        'Team up, build solutions and showcase your coding skills.',
    'capacity': 80,
    'image':
        'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=900',
  },
  {
    'id': 'sample3',
    'name': 'AI & Machine Learning Workshop',
    'category': 'Workshop',
    'date': '20 Dec 2026',
    'timings': '10:00 AM to 1:00 PM',
    'venue': 'Seminar Hall',
    'description':
        'Learn the fundamentals and applications of AI and machine learning.',
    'capacity': 60,
    'image':
        'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=900',
  },
  {
    'id': 'sample4',
    'name': 'Campus Sports Championship',
    'category': 'Sports',
    'date': '22 Dec 2026',
    'timings': '8:00 AM to 4:00 PM',
    'venue': 'College Sports Ground',
    'description':
        'Take part in exciting sports competitions across the campus.',
    'capacity': 120,
    'image':
        'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=900',
  },
  {
    'id': 'sample5',
    'name': 'Cultural Night',
    'category': 'Cultural',
    'date': '24 Dec 2026',
    'timings': '5:00 PM to 9:00 PM',
    'venue': 'Open Air Theatre',
    'description':
        'An evening of music, dance and cultural performances.',
    'capacity': 150,
    'image':
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=900',
  },
  {
    'id': 'sample6',
    'name': 'Career & Technology Seminar',
    'category': 'Seminar',
    'date': '28 Dec 2026',
    'timings': '10:00 AM to 2:00 PM',
    'venue': 'Main Seminar Hall',
    'description':
        'Explore career opportunities and emerging technologies.',
    'capacity': 75,
    'image':
        'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=900',
  },
];

// Shared booking list
List<Map<String, dynamic>> bookings = [];

class AttendeeDashboard extends StatelessWidget {
  const AttendeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(isOrganizer: false);
  }
}

class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(isOrganizer: true);
  }
}

class DashboardScreen extends StatefulWidget {
  final bool isOrganizer;

  const DashboardScreen({
    super.key,
    required this.isOrganizer,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedSection = 'Overview';
  String searchQuery = '';
  String selectedCategory = 'All';

  List<Map<String, dynamic>> customEvents = [];

  bool get isOrganizer => widget.isOrganizer;

  final List<String> categories = [
    'All',
    'Fest',
    'Technical',
    'Workshop',
    'Sports',
    'Cultural',
    'Seminar',
    'Other',
  ];

  List<Map<String, dynamic>> get allEvents {
    return [...sampleEvents, ...customEvents];
  }

  String eventKey(Map<String, dynamic> event) {
    return (event['id'] ?? event['name']).toString();
  }

  String eventTimings(Map<String, dynamic> event) {
    return event['timings']?.toString() ?? '9:00 AM to 5:00 PM';
  }

  int registrationCount(Map<String, dynamic> event) {
    return bookings.where((booking) {
      return booking['eventKey'] == eventKey(event);
    }).length;
  }

  int availableSeats(Map<String, dynamic> event) {
    final capacity = (event['capacity'] as num?)?.toInt() ?? 0;

    return (capacity - registrationCount(event))
        .clamp(0, capacity)
        .toInt();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBookings = prefs.getString('eventhub_bookings');
    final savedEvents = prefs.getString('eventhub_custom_events');

    if (!mounted) return;

    setState(() {
      if (savedBookings != null) {
        bookings = List<Map<String, dynamic>>.from(
          (jsonDecode(savedBookings) as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }

      if (savedEvents != null) {
        customEvents = List<Map<String, dynamic>>.from(
          (jsonDecode(savedEvents) as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }
    });
  }

  Future<void> saveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventhub_bookings', jsonEncode(bookings));
  }

  Future<void> saveEvents() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'eventhub_custom_events',
      jsonEncode(customEvents),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------------- NAVIGATION ----------------

  List<String> get menuItems {
    if (isOrganizer) {
      return [
        'Overview',
        'Create Event',
        'My Events',
        'Registrations',
      ];
    }

    return [
      'Overview',
      'Discover Events',
      'My Tickets',
    ];
  }

  IconData menuIcon(String item) {
    switch (item) {
      case 'Overview':
        return Icons.dashboard_outlined;
      case 'Discover Events':
        return Icons.explore_outlined;
      case 'My Tickets':
        return Icons.confirmation_number_outlined;
      case 'Create Event':
        return Icons.add_circle_outline;
      case 'My Events':
        return Icons.event_note_outlined;
      case 'Registrations':
        return Icons.people_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  void selectSection(String section, {bool inDrawer = false}) {
    setState(() {
      selectedSection = section;
    });

    if (inDrawer) {
      Navigator.pop(context);
    }
  }

  Widget buildSidebar({bool inDrawer = false}) {
    return Material(
      color: const Color(0xFF172238),
      child: Container(
        width: 245,
        padding: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 30),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: coral,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'EventHub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                isOrganizer
                    ? 'ORGANIZER WORKSPACE'
                    : 'ATTENDEE WORKSPACE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...menuItems.map((item) {
              final selected = selectedSection == item;

              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: ListTile(
                  selected: selected,
                  selectedTileColor: coral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  leading: Icon(
                    menuIcon(item),
                    color: selected
                        ? Colors.white
                        : const Color(0xFFDCE3EF),
                    size: 21,
                  ),
                  title: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  onTap: () => selectSection(
                    item,
                    inDrawer: inDrawer,
                  ),
                ),
              );
            }),
            const Spacer(),
            const Divider(color: Color(0xFF46516A)),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Discover. Register. Experience.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: ivory,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: navy,
            elevation: 1,
            title: Text(
              selectedSection,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: isMobile
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  )
                : null,
          ),
          drawer: isMobile
              ? Drawer(
                  child: buildSidebar(inDrawer: true),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile) buildSidebar(),
              Expanded(
                child: buildMainContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- MAIN CONTENT WITH ANIMATION ----------------

  Widget buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(selectedSection),
              child: _buildSelectedPage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPage() {
    switch (selectedSection) {
      case 'Discover Events':
        return buildExploreEvents();
      case 'My Tickets':
        return buildMyTickets();
      case 'Create Event':
        return buildCreateEventPage();
      case 'My Events':
        return buildMyEvents();
      case 'Registrations':
        return buildRegistrations();
      default:
        return buildOverview();
    }
  }

  // ---------------- OVERVIEW ----------------

  Widget buildOverview() {
    if (isOrganizer) {
      return _buildOrganizerOverview();
    }

    return _buildAttendeeOverview();
  }

  Widget _buildAttendeeOverview() {
    // Display the first three events in the overview.
    final recentEvents = allEvents.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to EventHub!',
          style: TextStyle(
            color: navy,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Find exciting events happening around your campus.',
          style: TextStyle(
            color: textGrey,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 25),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth < 550 ? 1 : 2;

            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: count == 1 ? 3.2 : 2.3,
              children: [
                _statCard(
                  'Available Events',
                  allEvents.length.toString(),
                  Icons.event_available,
                  coral,
                ),
                _statCard(
                  'My Bookings',
                  bookings.length.toString(),
                  Icons.confirmation_number,
                  navy,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        const Text(
          'Explore Campus Events',
          style: TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        // ListView.builder displays the recent events.
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentEvents.length,
          itemBuilder: (context, index) {
            final event = recentEvents[index];

            return Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.event, color: coral),
                title: Text(
                  event['name'].toString(),
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${event['date']} • ${event['venue']}',
                  style: const TextStyle(color: textGrey),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedSection = 'Discover Events';
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: coral,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: const Text('Explore Events'),
        ),
      ],
    );
  }

  Widget _buildOrganizerOverview() {
    final myRegistrationCount = bookings.where((booking) {
      return customEvents.any(
        (event) => booking['eventKey'] == eventKey(event),
      );
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ORGANIZER DASHBOARD',
                style: TextStyle(
                  color: coral,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome, Organizer!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create events, manage registrations and keep your campus activities organized.',
                style: TextStyle(
                  color: lightText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedSection = 'Create Event';
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'At a Glance',
          style: TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth < 550 ? 1 : 2;

            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: count == 1 ? 3.2 : 2.3,
              children: [
                _statCard(
                  'My Events',
                  customEvents.length.toString(),
                  Icons.event_note,
                  coral,
                ),
                _statCard(
                  'Total Registrations',
                  myRegistrationCount.toString(),
                  Icons.people_alt_outlined,
                  navy,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        const Text(
          'Recently Created Events',
          style: TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        if (customEvents.isEmpty)
          _emptyState(
            Icons.event_busy,
            'No Events Created',
            'Create your first event to get started.',
          )
        else
          ...customEvents.take(3).map((event) {
            final count = registrationCount(event);

            return Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color(0xFFE3E5EC),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lavenderGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: navy,
                  ),
                ),
                title: Text(
                  event['name'].toString(),
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${event['date']} • ${event['venue']}\n'
                    'Timings: ${eventTimings(event)}\n'
                    '$count registrations',
                    style: const TextStyle(
                      color: textGrey,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
                isThreeLine: true,
              ),
            );
          }),
        const SizedBox(height: 15),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              selectedSection = 'My Events';
            });
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('View All My Events'),
          style: OutlinedButton.styleFrom(
            foregroundColor: navy,
            side: const BorderSide(color: navy),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: color,
            width: 5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 29,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- EVENT CREATION / EDITING ----------------

  Widget buildCreateEventPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create a New Event',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Add your event details and make it available for students to discover.',
          style: TextStyle(color: textGrey, fontSize: 15),
        ),
        const SizedBox(height: 25),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 55,
                color: coral,
              ),
              const SizedBox(height: 15),
              const Text(
                'Ready to host an event?',
                style: TextStyle(
                  color: navy,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in the event name, category, date, timings, venue and capacity.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textGrey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => showEventForm(),
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coral,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> showEventForm({
    Map<String, dynamic>? existingEvent,
  }) async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: existingEvent?['name'] ?? '',
    );
    final dateController = TextEditingController(
      text: existingEvent?['date'] ?? '',
    );
    final timingsController = TextEditingController(
      text: existingEvent?['timings'] ?? '9:00 AM to 5:00 PM',
    );
    final venueController = TextEditingController(
      text: existingEvent?['venue'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingEvent?['description'] ?? '',
    );
    final capacityController = TextEditingController(
      text: (existingEvent?['capacity'] ?? 100).toString(),
    );

    String category = existingEvent?['category'] ?? 'Technical';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                existingEvent == null ? 'Create Event' : 'Edit Event',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _formField(
                          nameController,
                          'Event Name',
                          'Enter event name',
                        ),
                        const SizedBox(height: 13),
                        DropdownButtonFormField<String>(
                          initialValue: category,
                          decoration: _formDecoration('Category'),
                          items: categories
                              .where((item) => item != 'All')
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                category = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 13),
                        _formField(
                          dateController,
                          'Date',
                          'Example: 15 Dec 2026',
                        ),
                        const SizedBox(height: 13),
                        _formField(
                          timingsController,
                          'Timings',
                          'Example: 9:00 AM to 5:00 PM',
                        ),
                        const SizedBox(height: 13),
                        _formField(
                          venueController,
                          'Venue',
                          'Enter event venue',
                        ),
                        const SizedBox(height: 13),
                        _formField(
                          descriptionController,
                          'Description',
                          'Describe your event',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 13),
                        _formField(
                          capacityController,
                          'Maximum Participants',
                          'Enter capacity',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: textGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final capacity = int.tryParse(
                      capacityController.text.trim(),
                    );

                    if (capacity == null || capacity <= 0) return;

                    if (existingEvent != null &&
                        capacity < registrationCount(existingEvent)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Capacity cannot be lower than existing registrations.',
                          ),
                        ),
                      );
                      return;
                    }

                    final event = <String, dynamic>{
                      'id': existingEvent?['id'] ??
                          'EV${DateTime.now().microsecondsSinceEpoch}',
                      'name': nameController.text.trim(),
                      'category': category,
                      'date': dateController.text.trim(),
                      'timings': timingsController.text.trim(),
                      'venue': venueController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'capacity': capacity,
                      'image': existingEvent?['image'] ?? '',
                    };

                    setState(() {
                      if (existingEvent == null) {
                        customEvents.add(event);
                        selectedSection = 'My Events';
                      } else {
                        final index = customEvents.indexWhere(
                          (item) => item['id'] == existingEvent['id'],
                        );

                        if (index != -1) {
                          customEvents[index] = event;
                        }
                      }
                    });

                    await saveEvents();

                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);

                    showMessage(
                      existingEvent == null
                          ? 'Event created successfully!'
                          : 'Event updated successfully!',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coral,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    existingEvent == null ? 'Create' : 'Save Changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Controllers are intentionally not disposed here.
    // The dialog's closing transition may still be using them.
  }

  InputDecoration _formDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: coral,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _formDecoration(label).copyWith(
        hintText: hint,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }

        if (label == 'Maximum Participants') {
          final number = int.tryParse(value.trim());

          if (number == null || number <= 0) {
            return 'Enter a valid positive number';
          }
        }

        return null;
      },
    );
  }

  // ---------------- MY EVENTS ----------------

  Widget buildMyEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Events',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'View and manage the events you have created.',
          style: TextStyle(color: textGrey),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => showEventForm(),
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: coral,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 15),
        if (customEvents.isEmpty)
          _emptyState(
            Icons.event_busy,
            'No Events Created',
            'Create your first event to get started.',
          )
        else
          ...customEvents.map((event) {
            final count = registrationCount(event);
            final capacity = (event['capacity'] as num).toInt();

            return Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color(0xFFE3E5EC),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['name'].toString(),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${event['category']} • ${event['date']}\n'
                      'Timings: ${eventTimings(event)}\n'
                      'Venue: ${event['venue']}',
                      style: const TextStyle(
                        color: textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$count registered  •  ${availableSeats(event)} seats available',
                      style: const TextStyle(
                        color: textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: capacity == 0
                          ? 0
                          : (count / capacity).clamp(0.0, 1.0).toDouble(),
                      backgroundColor: lavenderGrey,
                      color: coral,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => showEventForm(
                            existingEvent: event,
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => deleteEvent(event),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> deleteEvent(Map<String, dynamic> event) async {
    if (registrationCount(event) > 0) {
      showMessage(
        'This event has registrations. You cannot delete it yet.',
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Do you want to delete "${event['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        customEvents.removeWhere(
          (item) => item['id'] == event['id'],
        );
      });

      await saveEvents();
      showMessage('Event deleted successfully.');
    }
  }

  // ---------------- REGISTRATIONS ----------------

  Widget buildRegistrations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Registrations',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track the registrations for your events.',
          style: TextStyle(color: textGrey),
        ),
        const SizedBox(height: 20),
        if (customEvents.isEmpty)
          _emptyState(
            Icons.people_outline,
            'No Events Yet',
            'Create an event to view its registrations.',
          )
        else
          ...customEvents.map((event) {
            final eventBookings = bookings.where((booking) {
              return booking['eventKey'] == eventKey(event);
            }).toList();

            return Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color(0xFFE3E5EC),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['name'].toString(),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${eventBookings.length} / ${event['capacity']} registrations',
                      style: const TextStyle(
                        color: textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (eventBookings.isEmpty)
                      const Text(
                        'No registrations for this event yet.',
                        style: TextStyle(color: textGrey),
                      )
                    else
                      ...eventBookings.map(
                        (booking) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: lavenderGrey,
                            child: Icon(
                              Icons.person_outline,
                              color: navy,
                            ),
                          ),
                          title: Text(
                            booking['eventName'].toString(),
                            style: const TextStyle(color: navy),
                          ),
                          subtitle: Text(
                            'Booking ID: ${booking['bookingId']}',
                            style: const TextStyle(color: textGrey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ---------------- EVENT DISCOVERY ----------------

  List<Map<String, dynamic>> get filteredEvents {
    return allEvents.where((event) {
      final matchesCategory = selectedCategory == 'All' ||
          event['category'] == selectedCategory;

      final query = searchQuery.toLowerCase();

      final matchesSearch =
          event['name'].toString().toLowerCase().contains(query) ||
          event['venue'].toString().toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget buildExploreEvents() {
    final events = filteredEvents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Find your next campus experience.',
                style: TextStyle(
                  color: lightText,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search events or venues...',
            prefixIcon: const Icon(
              Icons.search,
              color: navy,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final selected = selectedCategory == category;

            return ChoiceChip(
              label: Text(category),
              selected: selected,
              selectedColor: coral,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : navy,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) {
                setState(() {
                  selectedCategory = category;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          '${events.length} events found',
          style: const TextStyle(
            color: textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),
        if (events.isEmpty)
          _emptyState(
            Icons.search_off,
            'No Events Found',
            'Try another search or category.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850
                  ? 3
                  : constraints.maxWidth >= 550
                      ? 2
                      : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 385,
                ),
                itemBuilder: (context, index) {
                  return buildEventCard(events[index]);
                },
              );
            },
          ),
      ],
    );
  }

  Widget buildEventCard(Map<String, dynamic> event) {
    final seats = availableSeats(event);
    final image = event['image']?.toString() ?? '';

    return Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 145,
            width: double.infinity,
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _eventImageFallback();
                    },
                  )
                : _eventImageFallback(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: lavenderGrey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      event['category'].toString(),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event['name'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _smallInfo(
                    Icons.calendar_today,
                    event['date'].toString(),
                  ),
                  const SizedBox(height: 5),
                  _smallInfo(
                    Icons.access_time,
                    'Timings: ${eventTimings(event)}',
                  ),
                  const SizedBox(height: 5),
                  _smallInfo(
                    Icons.location_on_outlined,
                    event['venue'].toString(),
                  ),
                  const Spacer(),
                  Text(
                    seats > 0
                        ? '$seats seats available'
                        : 'Fully booked',
                    style: TextStyle(
                      color: seats > 0 ? textGrey : Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => showEventDetails(event),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: navy,
                            side: const BorderSide(color: navy),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: seats > 0
                              ? () => registerForEvent(event)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: coral,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventImageFallback() {
    return Container(
      color: lavenderGrey,
      child: const Center(
        child: Icon(
          Icons.event,
          size: 48,
          color: navy,
        ),
      ),
    );
  }

  Widget _smallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: textGrey,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> showEventDetails(
    Map<String, dynamic> event,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          event['name'].toString(),
          style: const TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event['description']?.toString() ??
                    'No description available.',
                style: const TextStyle(
                  color: textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              _smallInfo(
                Icons.category_outlined,
                event['category'].toString(),
              ),
              const SizedBox(height: 8),
              _smallInfo(
                Icons.calendar_today,
                event['date'].toString(),
              ),
              const SizedBox(height: 8),
              _smallInfo(
                Icons.access_time,
                'Timings: ${eventTimings(event)}',
              ),
              const SizedBox(height: 8),
              _smallInfo(
                Icons.location_on_outlined,
                event['venue'].toString(),
              ),
              const SizedBox(height: 8),
              _smallInfo(
                Icons.event_seat_outlined,
                '${availableSeats(event)} seats available',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(color: navy),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- REGISTRATION ----------------

  Future<void> registerForEvent(
    Map<String, dynamic> event,
  ) async {
    await loadData();

    final key = eventKey(event);

    final alreadyRegistered = bookings.any(
      (booking) => booking['eventKey'] == key,
    );

    if (alreadyRegistered) {
      showMessage('You have already registered for this event.');
      return;
    }

    if (availableSeats(event) <= 0) {
      showMessage('Sorry, this event is fully booked.');
      return;
    }

    final bookingId =
        'EH${DateTime.now().microsecondsSinceEpoch}';

    final booking = <String, dynamic>{
      'eventKey': key,
      'eventName': event['name'],
      'category': event['category'],
      'date': event['date'],
      'timings': eventTimings(event),
      'venue': event['venue'],
      'bookingId': bookingId,
    };

    setState(() {
      bookings.add(booking);
    });

    await saveBookings();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 15),
            const Text(
              'Registration Successful!',
              style: TextStyle(
                color: navy,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              event['name'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: textGrey),
            ),
            const SizedBox(height: 15),
            const Text(
              'Your Booking ID',
              style: TextStyle(color: textGrey),
            ),
            SelectableText(
              bookingId,
              style: const TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your ticket is available in My Tickets.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGrey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: coral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ---------------- MY TICKETS ----------------

  Widget buildMyTickets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Tickets',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'View your event registrations and booking details.',
          style: TextStyle(color: textGrey),
        ),
        const SizedBox(height: 20),
        if (bookings.isEmpty)
          _emptyState(
            Icons.confirmation_number_outlined,
            'No Tickets Yet',
            'Explore events and register to get your first ticket.',
          )
        else
          ...bookings.map(
            (booking) => Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['eventName'].toString(),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${booking['category']} • ${booking['date']}',
                      style: const TextStyle(color: textGrey),
                    ),
                    const SizedBox(height: 8),
                    _smallInfo(
                      Icons.access_time,
                      'Timings: ${booking['timings'] ?? '9:00 AM to 5:00 PM'}',
                    ),
                    const SizedBox(height: 5),
                    _smallInfo(
                      Icons.location_on_outlined,
                      booking['venue'].toString(),
                    ),
                    const Divider(height: 25),
                    const Text(
                      'BOOKING ID',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SelectableText(
                      booking['bookingId'].toString(),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => cancelBooking(booking),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel Registration'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> cancelBooking(
    Map<String, dynamic> booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Registration?'),
        content: Text(
          'Are you sure you want to cancel your registration for "${booking['eventName']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Ticket'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Registration'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        bookings.removeWhere(
          (item) => item['bookingId'] == booking['bookingId'],
        );
      });

      await saveBookings();

      showMessage(
        'Registration cancelled. The seat is available again.',
      );
    }
  }

  // ---------------- EMPTY STATE ----------------

  Widget _emptyState(
    IconData icon,
    String title,
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: navy,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textGrey),
          ),
          if (!isOrganizer) ...[
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedSection = 'Discover Events';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: coral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Explore Events'),
            ),
          ],
        ],
      ),
    );
  }
}