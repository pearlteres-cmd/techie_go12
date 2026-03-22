// lib/screens/customer/customer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:techie_go/screens/customer/complaint_form.dart';
import 'package:techie_go/screens/customer/track_complaint.dart';
import 'package:techie_go/widgets/complaint_card.dart';
import 'package:techie_go/widgets/stat_card.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const ComplaintHistory(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComplaintForm(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4361EE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF4361EE).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Color(0xFF4361EE),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF4361EE)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            children: const [
              StatCard(
                icon: Icons.pending_actions,
                value: '2',
                label: 'Pending',
                color: Color(0xFFFFD166),
              ),
              StatCard(
                icon: Icons.build,
                value: '1',
                label: 'In Progress',
                color: Color(0xFF4CC9F0),
              ),
              StatCard(
                icon: Icons.check_circle,
                value: '5',
                label: 'Resolved',
                color: Color(0xFF06D6A0),
              ),
              StatCard(
                icon: Icons.star,
                value: '4.2',
                label: 'Rating',
                color: Color(0xFFF72585),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComplaintForm(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('New Complaint'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrackComplaint(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Track'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CC9F0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Complaints
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Complaints',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: null,
                child: Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              ComplaintCard(
                id: '#TC2025001',
                serviceType: 'Laptop Repair',
                date: '2025-01-15',
                status: 'In Progress',
                technician: 'Alex Johnson',
              ),
              SizedBox(height: 12),
              ComplaintCard(
                id: '#TC2025002',
                serviceType: 'Software Installation',
                date: '2025-01-10',
                status: 'Pending',
                technician: '-',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ComplaintHistory extends StatelessWidget {
  const ComplaintHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complaint History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View all your past and current complaints',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                const FilterChip(
                  label: Text('Pending'),
                  selected: false,
                  onSelected: null,
                ),
                const SizedBox(width: 8),
                const FilterChip(
                  label: Text('In Progress'),
                  selected: false,
                  onSelected: null,
                ),
                const SizedBox(width: 8),
                const FilterChip(
                  label: Text('Resolved'),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Complaints List
          const Column(
            children: [
              ComplaintCard(
                id: '#TC2025001',
                serviceType: 'Laptop Repair',
                date: '2025-01-15',
                status: 'In Progress',
                technician: 'Alex Johnson',
              ),
              SizedBox(height: 12),
              ComplaintCard(
                id: '#TC2025002',
                serviceType: 'Software Installation',
                date: '2025-01-10',
                status: 'Pending',
                technician: '-',
              ),
              SizedBox(height: 12),
              ComplaintCard(
                id: '#TC2024128',
                serviceType: 'Virus Removal',
                date: '2024-12-28',
                status: 'Resolved',
                technician: 'Sarah Miller',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF4361EE),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customer',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
